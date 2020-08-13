#!/usr/bin/env bash
# helper script for build-paws-layer.sh
# you should not run this script directly.

set -uex

TAG=$1
cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime.zip"

# workaround for "xlocale.h: No such file or directory"
ln -s /usr/include/locale.h /usr/include/xlocale.h

/opt/bin/cpanm --notest --no-man-pages Paws

# install perlstrip
# https://metacpan.org/pod/distribution/Perl-Strip/bin/perlstrip
yum install -y parallel perl-App-cpanminus
cpanm --notest Perl::Strip

set +e # skip errors of stripping

find /opt/lib/perl5/site_perl -type f -a -name '*.pm' -print0 | parallel -0 /var/task/author/perlstrip.sh
find /opt/lib/perl5/site_perl -type f -a -name '*.pod' -print0 | xargs -0 rm
