#!/usr/bin/env bash
# helper script for build-perl-runtime-2.sh
# you should not run this script directly.

set -uex

PERL_VERSION=$1

curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt --noman -Dvendorprefix=/opt

# some libraries are missing in the image for running.
cp -R /lib64/libcrypt[.-]* /opt/lib/
cp -R /usr/lib64/libcurl.* /opt/lib/

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

# autodie is included in perl core, but the system perl of the Lambda Runtime lacks it.
yum install -y perl-autodie

# remove POD(Plain Old Documentation)
curl -s https://raw.githubusercontent.com/pplu/p5-pod-stripper/feature/fatpack/fatpacked/pod_stripper.pl > /tmp/pod_stripper.pl
perl /tmp/pod_stripper.pl /opt/lib/perl5
