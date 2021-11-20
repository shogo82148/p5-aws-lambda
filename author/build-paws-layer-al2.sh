#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.34.0 5-34
    $0 5.32.1 5-32
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/$PERL_VERSION-paws.al2"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT-x86_64"
rm -rf "$OPT-arm64"
mkdir -p "$OPT-x86_64/lib/perl5/site_perl"
mkdir -p "$OPT-arm64/lib/perl5/site_perl"
rm -f "$DIST/perl-$TAG-paws-al2-x86_64.zip"
rm -f "$DIST/perl-$TAG-paws-al2-arm64.zip"

docker run --rm \
    -v "$ROOT:/var/task" \
    -v "$OPT-x86_64/lib/perl5/site_perl:/opt/lib/perl5/site_perl" \
    --platform linux/amd64 \
    public.ecr.aws/shogo82148/lambda-provided:build-al2-x86_64 \
    ./author/build-paws-al2.sh "$TAG"
docker run --rm \
    -v "$ROOT:/var/task" \
    -v "$OPT-arm64/lib/perl5/site_perl:/opt/lib/perl5/site_perl" \
    --platform linux/arm64 \
    public.ecr.aws/shogo82148/lambda-provided:build-al2-arm64 \
    ./author/build-paws-al2.sh "$TAG"

cd "$OPT-x86_64"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-paws-al2-x86_64.zip" .

cd "$OPT-arm64"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-paws-al2-arm64.zip" .
