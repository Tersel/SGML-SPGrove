#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: simple-dump.pl,v 1.1 1997/10/07 00:51:03 ken Exp $
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

foreach $doc (@ARGV) {
    $grove = SGML::SPGrove->new ($doc);

    # note the extra argument `0', for no depth yet
    $grove->accept (SimpleDump->new, 0);
}


#
# SimpleDump carries an extra argument that is the current depth.
#

package SimpleDump;

use strict;

sub new {
    my ($type) = shift;

    return (bless {}, $type);
}

sub visit_grove {
    my ($self) = shift;
    my ($grove) = shift;
    my ($depth) = shift;

    print ("  " x $depth . "grove $grove\n");
    $grove->root->accept ($self, $depth + 1, @_);
}

sub visit_element {
    my ($self) = shift;
    my ($element) = shift;
    my ($depth) = shift;

    print ("  " x $depth . $element->gi . "\n");
    $element->children_accept ($self, $depth + 1, @_);
}

sub visit_sdata {
    my ($self) = shift;
    my ($sdata) = shift;
    my ($depth) = shift;

    print ("  " x $depth . "&" . $sdata->data . "\n");
}

sub visit_scalar {
    my ($self) = shift;
    my ($scalar) = shift;
    my ($depth) = shift;

    print ("  " x $depth . '"' . $scalar . "\"\n");
}
