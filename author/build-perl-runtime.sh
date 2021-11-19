#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.34.0 5-34
    $0 5.32.1 5-32
    $0 5.30.3 5-30
    $0 5.28.3 5-28
    $0 5.26.3 5-26
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/$PERL_VERSION"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT"
mkdir -p "$OPT"
rm -f "$DIST/perl-$TAG-runtime-x86_64.zip"

# build the perl binary
docker run \
    -v "$ROOT:/var/task" \
    -v "$OPT:/opt" \
    --rm --platform linux/amd64 \
    public.ecr.aws/shogo82148/lambda-provided:build-alami \
    ./author/build-perl.sh "$PERL_VERSION"

# check the perl binary works on the emulation image
docker run \
    -v "$OPT:/opt" \
    --rm --platform linux/amd64 \
    --entrypoint /opt/bin/perl \
    public.ecr.aws/shogo82148/lambda-provided:alami \
    -V

# create zip archive
cd "$OPT"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime-x86_64.zip" .
