#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: AutoHash.pm,v 1.1 1997/10/11 00:01:42 ken Exp $
#

use strict;

package SGML::AutoHash;
use Carp;
use vars qw($AUTOLOAD);

=head1 NAME

SGML::AutoHash - generate visitor and accessor methods for subclasses

=head1 SYNOPSIS

    use SGML::AutoHash;

    package MyClass;
    @ISA = qw{SGML::AutoHash};

    my $fields = {
        'contents' => undef,	# default field for `push', `pop', etc.
        'foo' => undef,
        'bar' => undef,
    };

    sub fields {
	return $fields;
    }

=head1 DESCRIPTION

C<AutoHash> automatically generates package methods as they are needed
for the following methods:

    On the object itself:
        accept ($visitor[, ...])

    On the default field named `contents':
        push ($value)
        pop ()
        children_accept ($visitor[, ...])

    On all fields:
        push_FIELD ($value)
        pop_FIELD ()
        children_accept_FIELD ($visitor[, ...])>
        FIELD ()
        FIELD ($value)

The C<accept> methods cause a callback to C<$visitor> with C<$self> as
the first argument plus the rest of the arguments passed to
C<accept>.  This is implemented like:

    sub accept {
        my $self = shift; my $visitor = shift;
        $visitor->visit_MyClass ($self, @_);
    }

The C<children_accept> methods loop through the elements of the array
calling C<accept> on each element.

C<push> and C<pop> act like their respective array functions.

C<I<FIELD> ($value)> sets the value of I<FIELD>.  S<C<I<FIELD> ()>>
returns the value of I<FIELD>.

C<SSGML::Simple::Spec.pm> is a package that uses C<AutoHash>.
C<AutoHash> is comparable to the module C<Class::Template>.

=head1 AUTHOR

Ken MacLeod, ken@bitsko.slc.ut.us

=head1 SEE ALSO

  perl(1), Class::Template(3)

  perltoot - Tom's object-oriented tutorial for perl
  <http://www.perl.com/CPAN/doc/FMTEYEWTK/perltoot.html>

=cut

sub new {
    my ($type) = shift;

    my ($self) = {};
    bless ($self, $type);

    return ($self);
}

sub fields {
    return {};
}

#
# This AUTOLOAD creates new functions in `$self's package for
#
#    accept
#    children_accept_FIELD
#    push_FIELD
#    pop_FIELD
#    FIELD ([$value])
#
sub AUTOLOAD {
    my $self = $_[0];

    my $type = ref($self)
	or croak "$self is not an object";

    my $name = $AUTOLOAD;
    my ($class, $op);
    $name =~ m/(.*)::(push_|pop_|children_accept_)?([^:]+)$/;
    ($class, $op, $name) = ($1, $2, $3);
    return if ($name eq 'DESTROY'); # per perlbot(1)

    my $sub = <<EOFEOF;
package $class;

EOFEOF

    my $sub_name;
    if ($name eq 'accept') {
	$sub_name = $name;
	my $class_under;
	($class_under = $class) =~ s/::/_/g;
	$sub .= <<'EOFEOF';
sub accept {
  my $self = shift; my $visitor = shift;
  $visitor->visit_!class! ($self, @_);
}
EOFEOF
        $sub =~ s/!class!/$class_under/g;
    } else {
	if ($name eq 'children_accept') {
	    # default field for children_accept
	    $op = $sub_name = 'children_accept';
	    $name = 'contents';
	} elsif ($name eq 'push') {
	    $op = $sub_name = 'push';
	    $name  = 'contents';
	} elsif ($name eq 'pop') {
	    $op = $sub_name = 'pop';
	    $name = 'contents';
	} else {
	    $sub_name = "$op$name";
	}

	unless (exists $self->fields->{$name} ) {
	    croak "Can't access `$name' field in class $type";
	}

	if ($op =~ /children_accept_?/) {
	    $sub .= <<'EOFEOF';
sub !sub_name! {
  my $self = shift; my $visitor = shift;
  my $array = $self->{'!name!'};
  my $ii;
  for ($ii = 0; $ii <= $#{$array}; $ii ++) {
    my ($child) = $array->[$ii];
    if (!ref ($child)) {
      $visitor->visit_scalar ($child, @_);
    } else {
      $array->[$ii]->accept ($visitor, @_);
    }
  }
}
EOFEOF
	} elsif ($op =~ /push_?/) {
            $sub .= <<'EOFEOF';
sub !sub_name! {
    my $self = shift;
    return push (@{$self->{'!name!'}}, shift);
}
EOFEOF
	} elsif ($op =~ /pop_?/) {
            $sub .= <<'EOFEOF';
sub !sub_name! {
    my $self = shift;
    return pop (@{$self->{'!name!'}});
}
EOFEOF
	} else {
            $sub .= <<'EOFEOF';
sub !sub_name! {
    my $self = shift;
    if (@_) {
        return $self->{'!name!'} = shift;
    } else {
	return $self->{'!name!'};
    }
}
EOFEOF
	}
    }

    $sub =~ s/!sub_name!/$sub_name/g;
    $sub =~ s/!name!/$name/g;

    eval $sub;
    die $@ if $@;

    my $function = "${class}::$sub_name";
    goto &$function;
}

1;
