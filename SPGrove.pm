#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: SPGrove.pm,v 1.7 1997/11/03 17:32:02 ken Exp $
#

package SGML::SPGrove;

use SGML::Element;
use SGML::SData;
use SGML::PI;
use SGML::Notation;
use SGML::Entity;
use SGML::ExtEntity;
use SGML::SubDocEntity;

use strict;
use vars qw($VERSION @ISA @EXPORT);
use Class::Visitor;

visitor_class 'SGML::SPGrove', 'Class::Visitor::Base',
    [
     'errors' => '@',		# [0]
     'entities' => '%',		# [1]
     'notations' => '%',	# [2]
     'contents' => '@',		# [3]
];

package SGML::SPGrove;

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

$VERSION = '0.15';

bootstrap SGML::SPGrove $VERSION;

sub root {
    my $self = shift;

    return $self->contents->[0];
}

# synonomous to `accept'
sub accept_gi {
    my $self = shift;
    my $visitor = shift;

    $visitor->visit_SGML_SPGrove ($self, @_);
}

sub children_accept_gi {
    my $self = shift;

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
  $entities = $grove->entities;
  $notations = $grove->notations;

  $grove->as_string([$context, ...]);

  $grove->iter;

  $grove->accept($visitor, ...);
  $grove->accept_gi($visitor, ...);
  $grove->children_accept($visitor, ...);
  $grove->children_accept_gi($visitor, ...);

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

C<$grove-E<gt>errors> returns a reference to an array containing any
errors generated while parsing the document.

C<$grove-E<gt>entities> returns a reference to a hash containing any
entities referenced in this grove (as opposed to entities that may
have been declared but not used).

C<$grove-E<gt>notations> returns a reference to an array containing
any notations referenced in this grove.

C<$grove-E<gt>as_string> returns the entire grove as a string,
possibly modified by C<$context>.  See L<SGML::SData> and L<SGML::PI>
for more detail.

C<$grove->iter> returns an iterator for the grove object, see
C<Class::Visitor> for details.

C<$grove-E<gt>accept($visitor[, ...])> issues a call back to
S<C<$visitor-E<gt>visit_SGML_SPGrove($element[, ...])>>.  See examples
C<visitor.pl> and C<simple-dump.pl> for more information.

C<$grove-E<gt>accept_gi($visitor[, ...])> is implemented as a synonym
for C<accept>.

C<children_accept> and C<children_accept_gi> call C<accept> and
C<accept_gi>, respectively, on the root element.

=head1 AUTHOR

Ken MacLeod, ken@bitsko.slc.ut.us

=head1 SEE ALSO

perl(1), Text::EntityMap(3), SGML::Element(3), SGML::SData(3),
SGML::PI(3), Class::Visitor(3).
<http://www.jclark.com/>

=cut
