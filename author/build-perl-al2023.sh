#!/usr/bin/env bash
# helper script for build-perl-runtime-al2023.sh
# you should not run this script directly.

set -ueox pipefail

PERL_VERSION=$1

NET_SSLEAY_VERSION=1.96
CARTON_VERSION=v1.0.35
AWS_XRAY_VERSION=0.12
JSON_VERSION=4.11
JSON_XS_VERSION=4.06
CPANEL_JSON_XS_VERSION=4.83
JSON_MAYBEXS_VERSION=1.004008
YAML_VERSION=1.321
YAML_TINY_VERSION=1.76
YAML_XS_VERSION=v0.910.0
IO_SOCKET_SSL_VERSION=2.099
MOZILLA_CA_VERSION=20261105
LOCAL_LIB_VERSION=2.000029

# cpanm is taken from this App-cpanminus release and checked against CPANM_SHA256 before it runs.
# author/update-dependencies.sh updates these three together.
CPANM_VERSION=1.7049
CPANM_AUTHOR=MIYAGAWA
CPANM_SHA256=b9ffb88e62a06aa91bd7d5a28ef6bdbb942608aea90e3969aa29b33640035214


# build-provided.al2023 lacks some development packages
dnf install -y perl glibc-langpack-en openssl openssl-devel

JOBS=$(nproc)
curl -sL https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build
perl /tmp/perl-build "$PERL_VERSION" /opt --jobs="$JOBS" --noman -Dvendorprefix=/opt

# workaround for "xlocale.h: No such file or directory"
ln -s /usr/include/locale.h /usr/include/xlocale.h

# some libraries are missing in the image for running.
cp -R /lib64/libcrypt[.-]* /opt/lib/
# cp -R /usr/lib64/libcurl.* /opt/lib/

# AWS::Lambda is installed as vendor modules.
# site_perl is reserved for other AWS Lambda layers.
# and skip man page generation.
export PERL_MM_OPT="INSTALLDIRS=vendor CCFLAGS=-I/opt/include LIBS=-L/opt/lib INSTALLMAN1DIR=none INSTALLMAN3DIR=none"
export PERL_MB_OPT="--installdirs=vendor --ccflags=-I/opt/include --lddlflags=-L/opt/lib --config installman1dir= --config installsiteman1dir= --config installman3dir= --config installsiteman3dir="
export PERL_MM_USE_DEFAULT=1

# install pre-installed modules
# cpanm installs everything below into the layer, so fetch a pinned release over HTTPS only
# (no redirect to plain HTTP) and verify its SHA-256 before using it.
CPANM_TARBALL="App-cpanminus-$CPANM_VERSION.tar.gz"
curl --proto '=https' --proto-redir '=https' -fsSL -o "/tmp/$CPANM_TARBALL" \
    "https://www.cpan.org/authors/id/${CPANM_AUTHOR:0:1}/${CPANM_AUTHOR:0:2}/$CPANM_AUTHOR/$CPANM_TARBALL"
echo "$CPANM_SHA256  /tmp/$CPANM_TARBALL" | sha256sum -c -
tar -xzf "/tmp/$CPANM_TARBALL" -C /tmp "App-cpanminus-$CPANM_VERSION/bin/cpanm"
perl -pe 's(^#!.*perl$)(#!/opt/bin/perl)' "/tmp/App-cpanminus-$CPANM_VERSION/bin/cpanm" > /tmp/cpanm
install /tmp/cpanm /opt/bin/cpanm
curl -fsSL --compressed https://raw.githubusercontent.com/skaji/cpm/main/cpm | perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' > /tmp/cpm
install /tmp/cpm /opt/bin/cpm

# Net::SSLeay needs special CCFLAGS and LIBS to link
PERL_MM_OPT="INSTALLDIRS=vendor INSTALLMAN1DIR=none INSTALLMAN3DIR=none" /opt/bin/cpanm --notest "Net::SSLeay@$NET_SSLEAY_VERSION"

/opt/bin/cpanm --notest \
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
dnf install -y perl-ExtUtils-MakeMaker
cd author/pod-stripper
perl /opt/bin/cpanm --installdeps --notest .
perl ./scripts/pod_stripper.pl /opt/lib/perl5
