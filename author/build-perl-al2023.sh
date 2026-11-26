#!/usr/bin/env bash
# helper script for build-perl-runtime-al2023.sh
# you should not run this script directly.

set -uex

PERL_VERSION=$1

NET_SSLEAY_VERSION=1.96
# cpanm, carton and cpm patched to avoid insecure (plain HTTP) connections.
# https://github.com/shogo82148/actions-setup-perl/tree/main/bin
ACTIONS_SETUP_PERL_COMMIT=b45a6f48c90b0367842227f88a22400a9045794c
CPANM_SHA256=d49f75b12a2791241474c9635d666dd983ab2ca631a722e5150cbc6a142b931e
CARTON_SHA256=baf3f381cd151f64789e042723ac97b9393c9609850c36e4946cc0e956d03f04
CPM_SHA256=100c72a0662e835cc0d2fde99cea7fda8bd28f649ec43312f2f36d3c9e211ac6
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
# use the patched versions of cpanm, carton and cpm.
for SCRIPT in cpanm carton cpm; do
    curl -fsSL -o "/tmp/$SCRIPT" "https://raw.githubusercontent.com/shogo82148/actions-setup-perl/$ACTIONS_SETUP_PERL_COMMIT/bin/$SCRIPT"
done
echo "$CPANM_SHA256  /tmp/cpanm" | sha256sum -c -
echo "$CARTON_SHA256  /tmp/carton" | sha256sum -c -
echo "$CPM_SHA256  /tmp/cpm" | sha256sum -c -
for SCRIPT in cpanm carton cpm; do
    perl -i -pe 's(^#!.*perl$)(#!/opt/bin/perl)' "/tmp/$SCRIPT"
    install "/tmp/$SCRIPT" "/opt/bin/$SCRIPT"
done

# Net::SSLeay needs special CCFLAGS and LIBS to link
PERL_MM_OPT="INSTALLDIRS=vendor INSTALLMAN1DIR=none INSTALLMAN3DIR=none" /opt/bin/cpanm --notest "Net::SSLeay@$NET_SSLEAY_VERSION"

/opt/bin/cpanm --notest \
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
