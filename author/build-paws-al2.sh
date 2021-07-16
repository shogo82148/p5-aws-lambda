#!/usr/bin/env bash
# helper script for build-paws-layer-al2.sh
# you should not run this script directly.

set -uex

TAG=$1
cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime-al2.zip"

# workaround for "xlocale.h: No such file or directory"
ln -s /usr/include/locale.h /usr/include/xlocale.h

# build-provided.al2 lacks some development packages
yum install -y expat-devel openssl openssl-devel

/opt/bin/cpanm --notest --no-man-pages Paws@0.44

# install perlstrip
# https://metacpan.org/pod/distribution/Perl-Strip/bin/perlstrip
yum install -y parallel perl-App-cpanminus
cpanm --notest Perl::Strip

set +e # skip errors of stripping

find /opt/lib/perl5/site_perl -type f -a -name '*.pm' -print0 | parallel -0 /var/task/author/perlstrip.sh
find /opt/lib/perl5/site_perl -type f -a -name '*.pod' -print0 | xargs -0 rm
