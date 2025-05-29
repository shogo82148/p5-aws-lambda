#!/usr/bin/env bash
# helper script for build-perl-runtime-al2.sh
# you should not run this script directly.

set -uex

PERL_VERSION=$1

OPENSSL_VERSION=3.5.0

NET_SSLEAY_VERSION=1.94
CARTON_VERSION=v1.0.35
AWS_XRAY_VERSION=0.12
JSON_VERSION=4.10
JSON_XS_VERSION=4.03
CPANEL_JSON_XS_VERSION=4.39
JSON_MAYBEXS_VERSION=1.004008
YAML_VERSION=1.31
YAML_TINY_VERSION=1.76
YAML_XS_VERSION=v0.904.0
IO_SOCKET_SSL_VERSION=2.089
MOZILLA_CA_VERSION=20250202
LOCAL_LIB_VERSION=2.000029

# install Perl
JOBS=$(nproc)
curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt --jobs="$JOBS" --noman -Dvendorprefix=/opt

# workaround for "xlocale.h: No such file or directory"
ln -s /usr/include/locale.h /usr/include/xlocale.h

# install OpenSSL
(
    cd /tmp
    curl --retry 3 -sSL "https://github.com/openssl/openssl/archive/refs/tags/openssl-$OPENSSL_VERSION.tar.gz" -o openssl.tar.gz
    tar zxvf /tmp/openssl.tar.gz
    cd "openssl-openssl-$OPENSSL_VERSION"
    /opt/bin/perl Configure --prefix=/opt --openssldir=/opt "-Wl,-rpath,\$(LIBRPATH)"
    make -j "$JOBS" build_sw
    make install_sw
)

# AWS::Lambda is installed as vendor modules.
# site_perl is reserved for other AWS Lambda layers.
# and skip man page generation.
export PERL_MM_OPT="INSTALLDIRS=vendor CCFLAGS=-I/opt/include LIBS=-L/opt/lib INSTALLMAN1DIR=none INSTALLMAN3DIR=none"
export PERL_MB_OPT="--installdirs=vendor --ccflags=-I/opt/include --lddlflags=-L/opt/lib --config installman1dir= --config installsiteman1dir= --config installman3dir= --config installsiteman3dir="
export PERL_MM_USE_DEFAULT=1
export OPENSSL_PREFIX=/opt

# install pre-installed modules
curl -fsSL --compressed http://cpanmin.us | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpanm
install /tmp/cpanm /opt/bin/cpanm
curl -fsSL --compressed https://raw.githubusercontent.com/skaji/cpm/main/cpm | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpm
install /tmp/cpm /opt/bin/cpm

/opt/bin/cpanm --notest \
    "Net::SSLeay@$NET_SSLEAY_VERSION" \
    "Carton@$CARTON_VERSION" \
    "AWS::XRay@$AWS_XRAY_VERSION" \
    "JSON@$JSON_VERSION" \
    "Cpanel::JSON::XS@$CPANEL_JSON_XS_VERSION" \
    "JSON::XS@$JSON_XS_VERSION" \
    "JSON::MaybeXS@$JSON_MAYBEXS_VERSION" \
    "YAML@$YAML_VERSION" \
    "YAML::Tiny@$YAML_TINY_VERSION" \
    "YAML::XS@$YAML_XS_VERSION" \
    "IO::Socket::SSL@$IO_SOCKET_SSL_VERSION" \
    "Mozilla::CA@$MOZILLA_CA_VERSION" \
    "local::lib@$LOCAL_LIB_VERSION"
/opt/bin/cpanm --notest .

# replace shebang to the absolute path of perl
cp script/bootstrap /opt/
perl -i -pe 's(^#!perl$)(#!/opt/bin/perl)' /opt/bootstrap

# remove POD(Plain Old Documentation)
yum install -y perl-ExtUtils-MakeMaker
cd author/pod-stripper
perl /opt/bin/cpanm --installdeps .
perl ./scripts/pod_stripper.pl /opt/lib/perl5
