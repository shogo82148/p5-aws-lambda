#!/usr/bin/env bash

set -uex

PERL_VERSION=$1

curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt --noman -Dvendorprefix=/opt

# AWS::Lambda is installed as vendor modules.
# site_perl is reserved for other AWS Lambda layers.
PERL_MM_OPT="INSTALLDIRS=vendor"
export PERL_MM_OPT
PERL_MB_OPT="--installdirs=vendor"
export PERL_MB_OPT

/opt/bin/cpan -T App::cpanminus
/opt/bin/cpan -T .
/opt/bin/cpan -T AWS::XRay
cp script/bootstrap /opt/

# install perlstrip
# https://metacpan.org/pod/distribution/Perl-Strip/bin/perlstrip
yum install -y parallel perl-App-cpanminus
cpanm --notest Perl::Strip

find /opt -type f -a -name '*.pm' -print0 | parallel -0 perlstrip -v
find /opt -type f -a -name '*.pod' -print0 | xargs -0 rm
