Summary: Perl module for loading SGML, XML, and HTML
Name: SGML-SPGrove
Version: @VERSION@
Release: 1
Source: ftp://ftp.uu.net/vendor/bitsko/gdo/SGML-SPGrove-@VERSION@.tar.gz
Copyright: distributable
Group: Applications/Publishing/SGML
URL: http://www.bitsko.slc.ut.us/
Packager: ken@bitsko.slc.ut.us (Ken MacLeod)
BuildRoot: /tmp/SGML-SPGrove

#
# $Id: SGML-SPGrove.spec,v 1.3 1997/10/05 21:46:43 ken Exp $
#
# $Log: SGML-SPGrove.spec,v $
# Revision 1.3  1997/10/05 21:46:43  ken
# SGML-SPGrove.spec: fixed perl paths again
#
# Revision 1.2  1997/10/05 21:41:04  ken
# SGML-SPGrove.spec: fixed perl path in %files
#
# Revision 1.1  1997/10/05 21:11:17  ken
# MANIFEST: added COPYING, SGML-SPGrove.spec, ChangeLog
#
# README: updated to 0.02
#
# SGML-SPGrove, ChangeLog: added
#
# SPGrove.pm: dummied to 0.00 for `make-rel'
#
#

%description
A Perl 5 module for loading SGML, XML, and HTML document instances
using James Clark's SGML Parser (SP).

%prep
%setup

perl Makefile.PL INSTALLDIRS=perl

%build

make

%install

make PREFIX="${RPM_ROOT_DIR}/usr" pure_install

%files

%doc README COPYING Changes test.pl

%dir /usr/lib/perl5/i386-linux/5.003/auto/SGML/SPGrove
/usr/lib/perl5/i386-linux/5.003/auto/SGML/SPGrove/SPGrove.so
/usr/lib/perl5/i386-linux/5.003/auto/SGML/SPGrove/SPGrove.bs
/usr/lib/perl5/SGML/SData.pm
/usr/lib/perl5/SGML/SPGrove.pm
/usr/lib/perl5/SGML/PI.pm
/usr/lib/perl5/SGML/Element.pm
/usr/lib/perl5/man/man3/SGML::SData.3
/usr/lib/perl5/man/man3/SGML::SPGrove.3
/usr/lib/perl5/man/man3/SGML::PI.3
/usr/lib/perl5/man/man3/SGML::Element.3
