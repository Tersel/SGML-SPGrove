#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: Element.pm,v 1.6 1997/10/12 21:26:56 ken Exp $
#

# Internally, an SGML::Element is an array containing
#
#    [0] -- contents
#    [1] -- gi (name)
#    [2] -- attributes

package SGML::Element;

use strict;

=head1 NAME

SGML::Element - an element of an SGML, XML, or HTML document

=head1 SYNOPSIS

  $element->gi;
  $element->name;
  $element->attr ($attr[, $value]);
  $element->attr_as_string ($attr[, $context, ...]);
  $element->attributes;
  $element->contents;

  $element->as_string([$context, ...]);

  $element->accept($visitor, ...);
  $element->accept_gi($visitor, ...);
  $element->children_accept($visitor, ...);
  $element->children_accept_gi($visitor, ...);

=head1 DESCRIPTION

C<SGML::Element> objects are loaded by C<SGML::SPGrove>.  An
C<SGML::Element> contains a generic identifier, or name, for the
element, the elements attributes and the ordered contents of the
element.

C<$element-E<gt>gi> and C<$element-E<gt>name> are synonyms, they
return the generic identifier of the element.

C<$element-E<gt>attr> returns the array value of an attribute, if a
second argument is given then that value is assigned to the attribute
and returned.  When assigning a value, C<attr> can take an array, or
an object or scalar.  If given an object or scalar, C<attr> will
create an array value for it.

C<$element-E<gt>attr_as_string> returns the value of an attribute as a
string, possibly modified by C<$context>.

C<$element-E<gt>attributes> returns a reference to a hash containing
the attributes of the element.  The keys of the hash are the attribute
names and the values are references to an array containing scalars or
C<SGML::SData> objects.

C<$element-E<gt>contents> returns a reference to an array containing
the children of the element.  The contents of the element may contain
other elements, scalars, or C<SGML::SData> or C<SGML:PI> objects.

C<$element-E<gt>as_string> returns the entire hierarchy of this
element as a string, possibly modified by C<$context>.  See
L<SGML::SData> and L<SGML::PI> for more detail.

C<$element-E<gt>accept($visitor[, ...])> issues a call back to
S<C<$visitor-E<gt>visit_element($element[, ...])>>.  See examples
C<visitor.pl> and C<simple-dump.pl> for more information.

C<$element-E<gt>accept_gi($visitor[, ...])> issues a call back to
S<C<$visitor-E<gt>visit_gi_I<GI>($element[, ...])>> where I<GI> is the
generic identifier of this element.  C<accept_gi> maps strange
characters in the GI to underscore (`_') [XXX more specific].

C<children_accept> and C<children_accept_gi> call C<accept> and
C<accept_gi>, respectively, on each object in the element's content.

Element handles scalars internally for C<as_string>,
C<children_accept>, and C<children_accept_gi>.  For C<children_accept>
and C<children_accept_gi> (both), Element calls back with
S<C<$visitor-E<gt>visit_scalar($scalar[, ...])>>.

For C<as_string>, Element will use the string unless
C<$context-E<gt>{cdata_mapper}> is defined, in which case it returns the
result of calling the C<cdata_mapper> subroutine with the scalar and
the remaining arguments.  The actual implementation is:

    &{$context->{cdata_mapper}} ($scalar, @_);

=head1 AUTHOR

Ken MacLeod, ken@bitsko.slc.ut.us

=head1 SEE ALSO

perl(1), SGML::SPGrove(3), Text::EntityMap(3), SGML::SData(3),
SGML::PI(3).

=cut

sub contents {
    return $_[0]->[0];
}

sub gi {
    return $_[0]->[1];
}

sub name {
    return $_[0]->[1];
}

sub attr {
    my $self = shift;
    my $attr = shift;

    if (@_) {
	my $value = shift;
	if (ref ($value) eq 'ARRAY') {
	    return $self->[2]->{$attr} = $value;
	} else {
	    return $self->[2]->{$attr} = [$value];
	}	    
    } else {
	return $self->[2]->{$attr};
    }
}

# $element->attr_as_string($attr[, $context]);
sub attr_as_string {
    my $self = shift;
    my $attr = shift;

    my $value = $self->[2]->{$attr};
    return "" if !defined $value;

    my ($ii, @string);
    for ($ii = 0; $ii <= $#{$value}; $ii ++) {
	my ($child) = $value->[$ii];
	if (!ref ($child)) {
	    # XXX should use context for a CDATA mapper
	    push (@string, $child);
	} else {
	    push (@string, $child->as_string(@_));
	}
    }
    return (join ("", @string));
}

sub attributes {
    return $_[0]->[2];
}

# $element->as_string($context);
sub as_string {
    my ($self) = shift;

    my (@string);
    my ($ii);
    for ($ii = 0; $ii <= $#{$self->[0]}; $ii ++) {
	my ($child) = $self->[0][$ii];
	if (!ref ($child)) {
	    # XXX should use context for a CDATA mapper
	    push (@string, $child);
	} else {
	    push (@string, $child->as_string(@_));
	}
    }
    return (join ("", @string));
}

sub accept {
    my ($self) = shift;
    my ($visitor) = shift;

    $visitor->visit_element ($self, @_);
}

sub accept_gi {
    my ($self) = shift;
    my ($visitor) = shift;

    my ($gi) = $self->gi;

    # matched in SpecBuilder.pm
    $gi =~ s/[-]/_/g;
    my ($alias) = "visit_gi_" . $gi;
    $visitor->$alias ($self, @_);
}

sub children_accept {
    my ($self) = shift;
    my ($visitor) = shift;

    my ($ii);
    for ($ii = 0; $ii <= $#{$self->[0]}; $ii ++) {
	my ($child) = $self->[0][$ii];
	if (!ref ($child)) {
	    $visitor->visit_scalar ($child, @_);
	} else {
	    $child->accept ($visitor, @_);
	}
    }
}

sub children_accept_gi {
    my ($self) = shift;
    my ($visitor) = shift;

    my ($ii);
    for ($ii = 0; $ii <= $#{$self->[0]}; $ii ++) {
	my ($child) = $self->[0][$ii];
	if (!ref ($child)) {
	    $visitor->visit_scalar ($child, @_);
	} else {
	    $child->accept_gi ($visitor, @_);
	}
    }
}

1;
