#
# Copyright (C) 1997 Ken MacLeod
# See the file COPYING for distribution terms.
#
# $Id: visitor.pl,v 1.1 1997/10/07 00:51:03 ken Exp $
#

#
# `visitor' is a basic skeleton of a visitor class using the `accept'
# methods of objects in an SPGrove.
#
# By calling `accept' on an object in the grove, that object will call
# you right back using a method based on that objects class.  For
# example, when you call `accept' on an SGML::Element, the element
# will call you right back using `visit_element'.
#
# Instead of getting the array of an element's content and calling
# `accept' on each object, you can call `children_accept' on the
# element and the element will loop through the array calling `accept'
# on each object.  This is convenient because the element will handle
# the special case where an object is really a Perl SCALAR (it will
# call `visit_scalar').
#
# The first argument to `accept' is a Visitor object.  The remaining
# arguments are simply carried around for you.  `simple-dump.pl' is an
# example that uses extra arguments.
#

use SGML::SPGrove;

foreach $doc (@ARGV) {
    $grove = SGML::SPGrove->new ($doc);

    $grove->accept (Visitor->new);
}


#
# The visitor class is where all the dirty work happens.  There
# doesn't have to be anything in the Visitor object, but you can use
# it to carry around temporary information while you ``visit'' the
# grove.
#

package Visitor;

use strict;

sub new {
    my ($type) = shift;

    return (bless {}, $type);
}

sub visit_grove {
    my ($self) = shift;
    my ($grove) = shift;

#    print "visiting grove $grove\n";
    $grove->root->accept ($self, @_);
}

sub visit_element {
    my ($self) = shift;
    my ($element) = shift;

#    print "visiting element $element, " . $element->name . "\n";
    $element->children_accept ($self, @_);
}

sub visit_sdata {
    my ($self) = shift;
    my ($sdata) = shift;

#    print "visiting sdata $sdata, " . $sdata->data . "\n";
}

sub visit_scalar {
    my ($self) = shift;
    my ($scalar) = shift;

#    print "visiting scalar $scalar\n";
}
