#!/usr/bin/env bash

set -uex

TAG=$1
cd /opt
unzip "/var/task/.perl-layer/dist/perl-$TAG-runtime.zip"
/opt/bin/cpanm --notest --no-man-pages Paws

# install perlstrip
# https://metacpan.org/pod/distribution/Perl-Strip/bin/perlstrip
cpan -T Perl::Strip

set +e # skip errors of stripping

find /opt/lib/perl5/site_perl -type f -a -name '*.pm' | while read -r MODULE; do
    perlstrip -v -o "$MODULE.strip" "$MODULE" \
        && /opt/bin/perl -c "$MODULE.strip" \
        && mv "$MODULE.strip" "$MODULE"
    rm -f "$MODULE.strip"
done
