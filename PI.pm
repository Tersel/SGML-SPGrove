#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: PI.pm,v 1.4 1997/10/09 01:55:10 ken Exp $
#

# Internally, an SGML::PI is blessed scalar

package SGML::PI;

use strict;

=head1 NAME

SGML::PI - an SGML, XML, or HTML document processing instruction

=head1 SYNOPSIS

  $data = $pi->data;

  $pi->as_string([$context, ...]);

  $pi->accept($visitor, ...);
  $pi->accept_gi($visitor, ...);
  $pi->children_accept($visitor, ...);
  $pi->children_accept_gi($visitor, ...);

=head1 DESCRIPTION

C<SGML::PI> objects are loaded by C<SGML::SPGrove>.  An C<SGML::PI>
contains the data in a Processing Instruction (PI).

C<$pi-E<gt>data> returns the data of the PI object.

C<$pi-E<gt>as_string> returns an empty string.

C<$pi-E<gt>accept($visitor[, ...])> issues a call back to
S<C<$visitor-E<gt>visit_pi($sdata[, ...])>>.  See examples
C<visitor.pl> and C<simple-dump.pl> for more information.

C<$pi-E<gt>accept_gi($visitor[, ...])> is implemented as a synonym
for C<accept>.

C<children_accept> and C<children_accept_gi> do nothing.

=head1 AUTHOR

Ken MacLeod, ken@bitsko.slc.ut.us

=head1 SEE ALSO

perl(1), SGML::SPGrove(3), Text::EntityMap(3), SGML::Element(3),
SGML::SData(3).

=cut

sub data {
    return ${$_[0]};
}

sub as_string {
    my ($self) = shift;
    my ($context) = shift;

    return ("");
}

sub accept {
    my ($self) = shift;
    my ($visitor) = shift;

    $visitor->visit_pi ($self, @_);
}

# synonomous to `accept'
sub accept_gi {
    my ($self) = shift;
    my ($visitor) = shift;

    $visitor->visit_pi ($self, @_);
}

# these are here just for type compatibility
sub children_accept { }
sub children_accept_gi { }

1;
