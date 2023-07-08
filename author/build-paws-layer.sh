#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.38.0 5-38
    $0 5.36.0 5-36
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/$PERL_VERSION-paws"
DIST="$ROOT/.perl-layer/dist"
set -uex

# sanity check of required tools
command -v parallel # GNU parallel

# clean up
rm -rf "$OPT"
mkdir -p "$OPT/lib/perl5/site_perl"
rm -f "$DIST/perl-$TAG-paws-x86_64.zip"

docker run --rm \
    --platform linux/amd64 \
    -v "$ROOT:/var/task" \
    -v "$OPT/lib/perl5/site_perl:/opt/lib/perl5/site_perl" \
    public.ecr.aws/shogo82148/lambda-provided:build-alami \
    ./author/build-paws.sh "$TAG"

find "$OPT" -type f -a -name '*.pm' -print0 | parallel -0 -j 32 "$ROOT/author/perlstrip.sh"

cd "$OPT"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-paws-x86_64.zip" .
