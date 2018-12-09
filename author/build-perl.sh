#!/usr/bin/env bash

PERL_VERSION=$1

curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt/
curl -sL https://cpanmin.us | /opt/bin/perl - App::cpanminus
/opt/bin/cpanm -n .
cp bin/bootstrap /opt/
