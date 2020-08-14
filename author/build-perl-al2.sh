#!/usr/bin/env bash
# helper script for build-perl-runtime-al2.sh
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
PERL_MM_OPT="INSTALLDIRS=vendor CCFLAGS=-I/opt/include LIBS=-L/opt/lib"
export PERL_MM_OPT
PERL_MB_OPT="--installdirs=vendor --ccflags=-I/opt/include --lddlflags=-L/opt/lib"
export PERL_MB_OPT

/opt/bin/cpan -T App::cpanminus
/opt/bin/cpan -T .
/opt/bin/cpan -T AWS::XRay
cp script/bootstrap /opt/

# install expat for parsing XML
(
    EXPAT_VERSION=2.2.9
    cd /tmp
    curl -sL -o expat.tar.gz "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION//[.]/_}/expat-$EXPAT_VERSION.tar.gz"
    echo "4456e0aa72ecc7e1d4b3368cd545a5eec7f9de5133a8dc37fdb1efa6174c4947  expat.tar.gz" | sha256sum -c -
    tar zxf expat.tar.gz
    cd "/tmp/expat-$EXPAT_VERSION"
    ./configure --prefix=/opt
    make
    make install
)
env EXPATLIBPATH=/opt/lib EXPATINCPATH=/opt/include /opt/bin/cpan -T XML::Parser

# Many Web services are encrypted with SSL/TLS.
# install SSL/TLS modules for convenience.
# install OpenSSL
(
    OPENSSL_VERSION=1.1.1g
    cd /tmp
    curl -sL -o /tmp/openssl.tar.gz "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
    echo "ddb04774f1e32f0c49751e21b67216ac87852ceb056b75209af2443400636d46  openssl.tar.gz" | sha256sum -c -
    tar zxf openssl.tar.gz
    cd "/tmp/openssl-$OPENSSL_VERSION"
    ./config --prefix=/opt
    make
    make install_sw
)
# install SSL/TLS modules
/opt/bin/cpan -T Net::SSLeay
/opt/bin/cpan -T Mozilla::CA
/opt/bin/cpan -T IO::Socket::SSL

# autodie is included in perl core, but the system perl of the Lambda Runtime lacks it.
yum install -y perl-autodie

# remove POD(Plain Old Documentation)
curl -s https://raw.githubusercontent.com/pplu/p5-pod-stripper/feature/fatpack/fatpacked/pod_stripper.pl > /tmp/pod_stripper.pl
perl /tmp/pod_stripper.pl /opt/lib/perl5
