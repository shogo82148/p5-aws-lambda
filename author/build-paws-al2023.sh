#!/usr/bin/env bash
# helper script for build-paws-layer-al2023.sh
# you should not run this script directly.

set -uex

TAG=$1

PAWS_VERSION=null

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
/opt/bin/cpanm --notest --no-man-pages "Paws@$PAWS_VERSION"

# remove pods
find /opt/lib/perl5/site_perl -type f -a -name '*.pod' -delete
