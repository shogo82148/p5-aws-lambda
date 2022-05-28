#!/usr/bin/env bash
# helper script for build-perl-runtime.sh
# you should not run this script directly.

set -uex

PERL_VERSION=$1

JOBS=$(nproc)
curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt --jobs="$JOBS" --noman -Dvendorprefix=/opt

# build-provided lacks some development packages
yum install -y openssl openssl-devel

# AWS::Lambda is installed as vendor modules.
# site_perl is reserved for other AWS Lambda layers.
# and skip man page generation.
export PERL_MM_OPT="INSTALLDIRS=vendor CCFLAGS=-I/opt/include LIBS=-L/opt/lib INSTALLMAN1DIR=none INSTALLMAN3DIR=none"
export PERL_MB_OPT="--installdirs=vendor --ccflags=-I/opt/include --lddlflags=-L/opt/lib --config installman1dir= --config installsiteman1dir= --config installman3dir= --config installsiteman3dir="
export PERL_MM_USE_DEFAULT=1

# install pre-installed modules
curl -fsSL --compressed http://cpanmin.us | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpanm
install /tmp/cpanm /opt/bin/cpanm
curl -fsSL --compressed https://git.io/cpm | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpm
install /tmp/cpm /opt/bin/cpm

# Net::SSLeay needs special CCFLAGS and LIBS to link
PERL_MM_OPT="INSTALLDIRS=vendor INSTALLMAN1DIR=none INSTALLMAN3DIR=none" /opt/bin/cpanm --notest Net::SSLeay@1.92

/opt/bin/cpanm --notest \
    AWS::XRay@0.12 \
    JSON@4.06 \
    Cpanel::JSON::XS@4.27 \
    JSON::XS@4.03 \
    JSON::MaybeXS@1.004003 \
    YAML@1.30 \
    YAML::Tiny@1.73 \
    YAML::XS@0.83 \
    IO::Socket::SSL@2.072 \
    Mozilla::CA@20211001
/opt/bin/cpanm --notest .

# replace shebang to the absolute path of perl
cp script/bootstrap /opt/
perl -i -pe 's(^#!perl$)(#!/opt/bin/perl)' /opt/bootstrap

# autodie is included in perl core, but the system perl of the Lambda Runtime lacks it.
yum install -y perl-autodie

# remove POD(Plain Old Documentation)
curl -s https://raw.githubusercontent.com/pplu/p5-pod-stripper/feature/fatpack/fatpacked/pod_stripper.pl > /tmp/pod_stripper.pl
perl /tmp/pod_stripper.pl /opt/lib/perl5
