#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: simple-dump.pl,v 1.2 1997/11/03 17:32:11 ken Exp $
#

#
# `simple-dump' is another simple visitor class using the `accept'
# methods of objects in an SPGrove.  `simple-dump' outputs the groves
# in an indented format.  `simple-dump' is an example that passes an
# extra argument through the accept/visit cycles.
#
# `visitor.pl' gives a more detailed description of what `visiting'
# does.
#

use SGML::SPGrove;

my $doc;
foreach $doc (@ARGV) {
    my $grove = SGML::SPGrove->new ($doc);

    # note the extra argument `0', for no depth yet
    $grove->accept (SimpleDump->new, 0);
}


#
# SimpleDump carries an extra argument that is the current depth.
#

package SimpleDump;

use strict;

sub new {
    my $type = shift;

    return (bless {}, $type);
}

sub visit_SGML_SPGrove {
    my $self = shift;
    my $grove = shift;
    my $depth = shift;

    print ("  " x $depth . "grove $grove\n");
    $grove->children_accept ($self, $depth + 1, @_);
}

sub visit_SGML_Element {
    my $self = shift;
    my $element = shift;
    my $depth = shift;

    print ("  " x $depth . $element->gi . "\n");
    $element->children_accept ($self, $depth + 1, @_);
}

sub visit_SGML_SData {
    my $self = shift;
    my $sdata = shift;
    my $depth = shift;

    print ("  " x $depth . "&" . $sdata->data . "\n");
}

sub visit_SGML_PI {
    my $self = shift;
    my $pi = shift;
    my $depth = shift;

    print ("  " x $depth . "?" . $pi->data . "\n");
}

sub visit_SGML_Entity {
    my $self = shift;
    my $entity = shift;
    my $depth = shift;

    print ("  " x $depth . "<<" . $entity->name . "\n");
}

sub visit_SGML_ExtEntity {
    my $self = shift;
    my $ext_entity = shift;
    my $depth = shift;

    print ("  " x $depth . "<" . $ext_entity->name . "\n");
}

sub visit_SGML_SubDocEntity {
    my $self = shift;
    my $subdoc_entity = shift;
    my $depth = shift;

    print ("  " x $depth . "S<" . $subdoc_entity->name . "\n");
}

sub visit_scalar {
    my ($self) = shift;
    my ($scalar) = shift;
    my ($depth) = shift;

    $scalar =~ s/([\000-\037])/"\\" . sprintf ("%o", ord($1))/ge;
    print ("  " x $depth . '"' . $scalar . "\"\n");
}
