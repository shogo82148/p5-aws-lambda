#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.34.0 5-34
    $0 5.32.1 5-32
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/${PERL_VERSION}.al2"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT-x86_64"
rm -rf "$OPT-arm64"
mkdir -p "$OPT-x86_64"
mkdir -p "$OPT-arm64"
rm -f "$DIST/perl-$TAG-runtime-al2-x86_64.zip"
rm -f "$DIST/perl-$TAG-runtime-al2-arm64.zip"

# build the perl binary
docker run \
    -v "$ROOT:/var/task" \
    -v "$OPT-x86_64:/opt" \
    --rm --platform linux/amd64 \
    public.ecr.aws/shogo82148/lambda-provided:build-al2-x86_64 \
    ./author/build-perl-al2.sh "$PERL_VERSION"
docker run \
    -v "$ROOT:/var/task" \
    -v "$OPT-arm64:/opt" \
    --rm --platform linux/arm64 \
    public.ecr.aws/shogo82148/lambda-provided:build-al2-arm64 \
    ./author/build-perl-al2.sh "$PERL_VERSION"

# check the perl binary works on the emulation images
docker run \
    -v "$OPT-x86_64:/opt" \
    -v "$ROOT/examples/hello:/var/task" \
    --rm --platform linux/amd64 \
    --entrypoint /opt/bin/perl \
    public.ecr.aws/shogo82148/lambda-provided:al2-x86_64 -V
docker run \
    -v "$OPT-arm64:/opt" \
    --rm --platform linux/arm64 \
    --entrypoint /opt/bin/perl \
    public.ecr.aws/shogo82148/lambda-provided:al2-arm64 -V

# create zip archive
cd "$OPT-x86_64"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime-al2-x86_64.zip" .

cd "$OPT-arm64"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime-al2-arm64.zip" .
