#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: SPGrove.pm,v 1.6 1997/10/09 01:55:13 ken Exp $
#

# Internally, an SGML::SPGrove is an array containing
#
#    [0] -- errors
#    [1] -- root element

package SGML::SPGrove;

use SGML::Element;
use SGML::SData;
use SGML::PI;

use strict;
use vars qw($VERSION @ISA @EXPORT);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

$VERSION = '0.06';

bootstrap SGML::SPGrove $VERSION;

sub errors {
    return $_[0]->[0];
}
    
sub root {
    return $_[0]->[1];
}

# $grove->as_string($context);
sub as_string {
    my ($self) = shift;

    return ($self->root->as_string(@_));
}

sub accept {
    my ($self) = shift;
    my ($visitor) = shift;

    $visitor->visit_grove ($self, @_);
}

# synonomous to `accept'
sub accept_gi {
    my ($self) = shift;
    my ($visitor) = shift;

    $visitor->visit_grove ($self, @_);
}

sub children_accept {
    my ($self) = shift;

    $self->root->accept (@_);
}

sub children_accept_gi {
    my ($self) = shift;

    $self->root->accept_gi (@_);
}

1;
__END__

=head1 NAME

SGML::SPGrove - load an SGML, XML, or HTML document

=head1 SYNOPSIS

  use SGML::SPGrove;
  $grove = SGML::SPGrove->new ($sysid);
  $root = $grove->root;
  $errors = $grove->errors;

  $grove->as_string([$context, ...]);

  $grove->accept($visitor, ...);
  $grove->accept_gi($visitor, ...);
  $grove->children_accept($visitor, ...);
  $grove->children_accept($visitor, ...);

=head1 DESCRIPTION

C<new> loads an SGML, XML, or HTML document instance from C<$sysid>
using James Clark's SGML Parser (SP), returning a ``grove'' that
contains the root, or top, element of the document and an array of any
warnings or errors that may have been generated while parsing the
document.

Refer to ``System Identifiers'' in SP's documentation for a
description of C<$sysid>, which can be a file name, a URL, `C<->' for
standard input, a literal string ("C<E<lt>LITERALE<gt>$scalar>"), or a
formal system identifier.

C<$grove-E<gt>root> returns the C<SGML::Element> of the outermost
element of the document.

C<$grove-E<gt>errors> returns a reference to array containing any
errors generated while parsing the document.

C<$grove-E<gt>as_string> returns the entire grove as a string,
possibly modified by C<$context>.  See L<SGML::SData> and L<SGML::PI>
for more detail.

C<$grove-E<gt>accept($visitor[, ...])> issues a call back to
S<C<$visitor-E<gt>visit_grove($element[, ...])>>.  See examples
C<visitor.pl> and C<simple-dump.pl> for more information.

C<$grove-E<gt>accept_gi($visitor[, ...])> is implemented as a synonym
for C<accept>.

C<children_accept> and C<children_accept_gi> call C<accept> and
C<accept_gi>, respectively, on the root element.

=head1 AUTHOR

Ken MacLeod, ken@bitsko.slc.ut.us

=head1 SEE ALSO

perl(1), Text::EntityMap(3), SGML::Element(3), SGML::SData(3),
SGML::PI(3).
<http://www.jclark.com/>

=cut
