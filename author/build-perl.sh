#!/usr/bin/env bash
# helper script for build-perl-runtime.sh
# you should not run this script directly.

set -uex

PERL_VERSION=$1

JOBS=$(nproc)
curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt --jobs="$JOBS" --noman -Dvendorprefix=/opt

# build-provided.al2 lacks some development packages
yum install -y expat-devel openssl openssl-devel

# AWS::Lambda is installed as vendor modules.
# site_perl is reserved for other AWS Lambda layers.
PERL_MM_OPT="INSTALLDIRS=vendor CCFLAGS=-I/opt/include LIBS=-L/opt/lib"
export PERL_MM_OPT
PERL_MB_OPT="--installdirs=vendor --ccflags=-I/opt/include --lddlflags=-L/opt/lib"
export PERL_MB_OPT

# install pre-installed modules
curl -fsSL --compressed http://cpanmin.us | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpanm
install /tmp/cpanm /opt/bin/cpanm
curl -fsSL --compressed https://git.io/cpm | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpm
install /tmp/cpm /opt/bin/cpm
/opt/bin/cpanm --notest --no-man-pages \
    AWS::XRay@0.11 \
    JSON@4.03 \
    Cpanel::JSON::XS@4.26 \
    JSON::XS@4.03 \
    JSON::MaybeXS@1.004003 \
    YAML@1.30 \
    YAML::Tiny@1.73 \
    YAML::XS@0.83 \
    Net::SSLeay@1.90 \
    IO::Socket::SSL@2.072 \
    Mozilla::CA@20211001
cpanm --notest --no-man-pages .

# replace shebang to the absolute path of perl
cp script/bootstrap /opt/
perl -i -pe 's(^#!perl$)(#!/opt/bin/perl)' /opt/bootstrap

# autodie is included in perl core, but the system perl of the Lambda Runtime lacks it.
yum install -y perl-autodie

# remove POD(Plain Old Documentation)
curl -s https://raw.githubusercontent.com/pplu/p5-pod-stripper/feature/fatpack/fatpacked/pod_stripper.pl > /tmp/pod_stripper.pl
perl /tmp/pod_stripper.pl /opt/lib/perl5
