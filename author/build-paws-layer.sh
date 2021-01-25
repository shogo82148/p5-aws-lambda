#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.26.3 5-26
    $0 5.28.3 5-28
    $0 5.30.3 5-30
    $0 5.32.1 5-32
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/$PERL_VERSION-paws"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT"
mkdir -p "$OPT/lib/perl5/site_perl"
rm -f "$DIST/perl-$TAG-paws.zip"

docker run --rm \
    -v "$ROOT:/var/task" \
    -v "$OPT/lib/perl5/site_perl:/opt/lib/perl5/site_perl" \
    lambci/lambda:build-provided \
    ./author/build-paws.sh "$TAG"
cd "$OPT"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-paws.zip" .
