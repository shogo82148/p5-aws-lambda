#!/usr/bin/env bash
# helper script for build-perl-runtime.sh
# you should not run this script directly.

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

# replace shebang to the absolute path of perl
cp script/bootstrap /opt/
perl -i -pe 's(^#!perl$)(#!/opt/bin/perl)' /opt/bootstrap

# autodie is included in perl core, but the system perl of the Lambda Runtime lacks it.
yum install -y perl-autodie

# remove POD(Plain Old Documentation)
curl -s https://raw.githubusercontent.com/pplu/p5-pod-stripper/feature/fatpack/fatpacked/pod_stripper.pl > /tmp/pod_stripper.pl
perl /tmp/pod_stripper.pl /opt/lib/perl5
