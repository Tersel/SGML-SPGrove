Summary: Perl module for loading SGML, XML, and HTML
Name: SGML-SPGrove
Version: 0.15
Release: 1
Source: ftp://ftp.uu.net/vendor/bitsko/gdo/SGML-SPGrove-0.15.tar.gz
Copyright: distributable
Group: Applications/Publishing/SGML
URL: http://www.bitsko.slc.ut.us/
Packager: ken@bitsko.slc.ut.us (Ken MacLeod)
BuildRoot: /tmp/SGML-SPGrove

#
# $Id: SGML-SPGrove.spec,v 1.6 1997/11/06 19:21:54 ken Exp $
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

%doc README COPYING Changes DOM test.pl

%dir /usr/lib/perl5/i386-linux/5.003/auto/SGML/SPGrove
/usr/lib/perl5/i386-linux/5.003/auto/SGML/SPGrove/SPGrove.so
/usr/lib/perl5/i386-linux/5.003/auto/SGML/SPGrove/SPGrove.bs
/usr/lib/perl5/SGML/SData.pm
/usr/lib/perl5/SGML/SPGrove.pm
/usr/lib/perl5/SGML/PI.pm
/usr/lib/perl5/SGML/Element.pm
/usr/lib/perl5/SGML/Entity.pm
/usr/lib/perl5/SGML/ExtEntity.pm
/usr/lib/perl5/SGML/Notation.pm
/usr/lib/perl5/SGML/SubDocEntity.pm
/usr/lib/perl5/SGML/Writer.pm
/usr/lib/perl5/SGML/Simple/BuilderBuilder.pm
/usr/lib/perl5/SGML/Simple/SpecBuilder.pm
/usr/lib/perl5/SGML/Simple/Spec.pm
/usr/lib/perl5/man/man3/SGML::SData.3
/usr/lib/perl5/man/man3/SGML::SPGrove.3
/usr/lib/perl5/man/man3/SGML::PI.3
/usr/lib/perl5/man/man3/SGML::Element.3
/usr/lib/perl5/man/man3/SGML::Simple::BuilderBuilder.3
/usr/lib/perl5/man/man3/SGML::Simple::SpecBuilder.3
/usr/lib/perl5/man/man3/SGML::Simple::Spec.3
