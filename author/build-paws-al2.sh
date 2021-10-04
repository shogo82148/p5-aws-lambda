#!/usr/bin/env bash
# helper script for build-paws-layer-al2.sh
# you should not run this script directly.

set -uex

TAG=$1

# provided.al2 lacks some development packages
yum install -y expat-devel

case $(uname -m) in
  "x86_64")
    ARCH=x86_64;;
  "aarch64")
    ARCH=arm64;;
  *)
    echo "unknown architecture: $(uname -m)"
esac

cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime-al2-$ARCH.zip"

/opt/bin/cpanm --notest --no-man-pages Paws@0.44

# install perlstrip
# https://metacpan.org/pod/distribution/Perl-Strip/bin/perlstrip
yum install -y parallel perl-App-cpanminus
cpanm --notest Perl::Strip

set +e # skip errors of stripping

find /opt/lib/perl5/site_perl -type f -a -name '*.pm' -print0 | parallel -0 /var/task/author/perlstrip.sh
find /opt/lib/perl5/site_perl -type f -a -name '*.pod' -print0 | xargs -0 rm
