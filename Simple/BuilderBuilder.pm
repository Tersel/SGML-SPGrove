#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: BuilderBuilder.pm,v 1.1 1997/10/11 00:01:53 ken Exp $
#

package SGML::Simple::BuilderBuilder;

use strict;

=head1 NAME

SGML::Simple::BuilderBuilder - build a simple transformation package

=head1 SYNOPSIS

    use SGML::SPGrove;
    use SGML::Simple::Spec;
    use SGML::Simple::SpecBuilder;
    use SGML::Simple::BuilderBuilder;

    $spec_grove = SGML::SPGrove->new ($spec_sysid);
    $spec = SGML::Simple::Spec->new;
    $spec_grove->accept (SGML::Simple::SpecBuilder->new, $spec);
    $builder = SGML::Simple::BuilderBuilder->new ($spec);

    $grove = SGML::SPGrove->new ($sysid);
    $object_tree_root = My::Object->new();
    $grove->accept ($builder->new, $object_tree_root);

=head1 DESCRIPTION

C<BuilderBuilder> returns the package name of a package built using a
specification read from a specification file.

Passing a new ``builder'' to C<accept_gi> of a grove will cause an
output object tree to be generated under C<$object_tree_root> using
the builder.

C<Builder> packages are all singletons, calling C<new> always returns
the same object.

=head1 AUTHOR

Ken MacLeod, ken@bitsko.slc.ut.us

=head1 SEE ALSO

  perl(1), SGML::SPGrove(3), SGML::Simple::Spec(3),
  SGML::Simple::SpecBuilder(3)

=cut

# technically, after `BB9999' this will roll to `BC0000' :-)
my $next_package = "BB0000";

sub new {
    my $type = shift;
    my $spec = shift;

    my $package = $next_package++;
    new_package ($package, 'NoSuchGI_');

    my $self = {
	'default_object' => $spec->default_object,
	'default_prefix' => $spec->default_prefix,
    };
    bless ($self, $type);

    $spec->accept ($self, $package);

    return ($package);
}

sub visit_SGML_Simple_Spec {
    my $self = shift;
    my $spec = shift;
    my $package = shift;

    $spec->children_accept_rules ($self, $package, @_);
}

sub visit_SGML_Simple_Spec_Rule {
    my $self = shift;
    my $rule = shift;
    my $package = shift;

    my $sub_builder = "";
    if (defined $rule->{rules}) {
	# XXX support sharing of sub-rules
	my $sub_package = $next_package++;

	my $str = <<EOFEOF;
package $sub_package;
\@${sub_package}::ISA = qw{$package};

my \$singleton = undef;

sub new {
    my \$type = shift;

    return (\$singleton)
	if (defined \$singleton);

    my \$self = {};
    bless (\$self, \$type);
    \$singleton = \$self;

    return \$self;
}
EOFEOF
        eval $str;
        die "BuilderBuilder::visit_SGML_Simple_Spec: unable to compile rule\n"
          . "$str\n$@\n"
            if $@;

	# we cheat a little by redefining `$self'
	$sub_builder = "\$self = $sub_package->new;";
	$rule->children_accept_rules ($self, $sub_package, @_);
    }

    my $sub = "";

    if ($rule->{holder}) {
	$sub = <<EOFEOF;
  my \$self = shift; my \$element = shift;
  $sub_builder
  \$element->children_accept_gi (\$self, \@_);
EOFEOF
    } elsif ($rule->{code}) {
	$sub = $rule->{code};
    } else {
        my $make = "my \$obj = new $self->{'default_object'};";
        if (defined $rule->{make}) {
	    # use a little perl trick here, "new THING ()" is the
	    # same as "THING->new ()" and `$rule->{make}' already
	    # has parens
	    # XXX check to see if class has been loaded
	    $make = "my \$obj = new $self->{'default_prefix'}::$rule->{make};";
	}

	my $push = "\$parent->push (\$obj);";
	if (defined $rule->{port}) {
	    $push = "\$parent->push_$rule->{port}(\$obj);";
	}

	$sub = <<EOFEOF;
  my \$self = shift; my \$element = shift; my \$parent = shift;
  $make
  $push
  $sub_builder
  \$element->children_accept_gi (\$self, \$obj);
EOFEOF
    }

    # create the rule subroutine
    my @gis = split (/\s+/, $rule->{query});
    my $gi;
    foreach $gi (@gis) {
        my $retval = eval <<EOFEOF;
package $package;

sub visit_gi_$gi {
$sub
}

EOFEOF
        die "BuilderBuilder::visit_SGML_Simple_Spec_Rule: unable to compile rule\n"
          . "$sub\n$@\n"
            if $@;
    }
}

sub new_package {
    my $new_package = shift;
    my $super_package = shift;

    my $str = <<'EOFEOF';
package !new_package!;
@!new_package!::ISA = qw{!super_package!};

my $singleton = undef;

sub new {
    my $type = shift;

    return ($singleton)
	if (defined $singleton);

    my $self = {};
    bless ($self, $type);
    $singleton = $self;

    return $self;
}

sub visit_grove {
    my $self = shift; my $grove = shift;

    # XXX capture grove information to built object?
    $grove->children_accept_gi ($self, @_);
}

sub visit_scalar {
    my $self = shift; my $scalar = shift; my $parent = shift;

    # XXX cdata_mapper?
    $parent->push ($scalar);
}

sub visit_sdata {
    my $self = shift; my $sdata = shift; my $parent = shift;

    # XXX sdata_mapper?
    $parent->push ($sdata);
}

# XXX PI, entities?
EOFEOF
    $str =~ s/!new_package!/$new_package/g;
    $str =~ s/!super_package!/$super_package/g;
    eval $str;
    die "BuilderBuilder::visit_SGML_Simple_Spec: unable to compile rule\n"
      . "$str\n$@\n"
        if $@;
}

package NoSuchGI_;

use Carp;
use vars qw{$AUTOLOAD};

sub AUTOLOAD {
    my $self = shift; my $visted = shift;
    my $obj = shift; my $context = shift;

    my $type = ref($self)
	or croak "$self is not an object";

    my $name = $AUTOLOAD;
    my ($class, $op);
    $name =~ m/(.*)::(visit_gi_)?([^:]+)$/;
    ($class, $op, $name) = ($1, $2, $3);
    return if ($name eq 'DESTROY'); # per perlbot(1)

    if ($op eq 'visit_gi_') {
	carp "$name not handled\n";
    } else {
	croak "$AUTOLOAD: huh?\n";
    }
}

1;