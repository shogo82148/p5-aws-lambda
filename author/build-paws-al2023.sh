#!/usr/bin/env bash
# helper script for build-paws-layer-al2023.sh
# you should not run this script directly.

set -uex

TAG=$1

PAWS_VERSION=0.46
# PAUSE ID that uploaded Paws-$PAWS_VERSION.tar.gz (kept in sync by update-dependencies.sh)
PAWS_AUTHOR=JROBINSON

# install development packages
dnf install -y glibc-langpack-en expat-devel

case $(uname -m) in
  "x86_64")
    ARCH=x86_64;;
  "aarch64")
    ARCH=arm64;;
  *)
    echo "unknown architecture: $(uname -m)"
esac

cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime-al2023-$ARCH.zip"
# fetch Paws and its dependencies only from the HTTPS CPAN mirror
/opt/bin/cpanm --notest --no-man-pages --from https://www.cpan.org "$PAWS_AUTHOR/Paws-$PAWS_VERSION.tar.gz"

# remove pods
find /opt/lib/perl5/site_perl -type f -a -name '*.pod' -delete
