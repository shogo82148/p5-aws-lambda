#!/usr/bin/env bash

set -uex

TAG=$1
cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime.zip"
/opt/bin/cpanm --notest --no-man-pages Paws

# install perlstrip
# https://metacpan.org/pod/distribution/Perl-Strip/bin/perlstrip
yum install -y parallel
cpan -T Perl::Strip

set +e # skip errors of stripping

find /opt/lib/perl5/site_perl -type f -a -name '*.pm' -print0 | parallel -0 perlstrip -v
find /opt/lib/perl5/site_perl -type f -a -name '*.pod' -print0 | xargs -0 rm
