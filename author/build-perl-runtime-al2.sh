#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.32.1 5-32
    $0 5.34.0 5-34
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/${PERL_VERSION}.al2"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT"
mkdir -p "$OPT"
rm -f "$DIST/perl-$TAG-runtime-al2.zip"

# build the perl binary
docker run -v "$ROOT:/var/task" -v "$OPT:/opt" --rm lambci/lambda:build-provided.al2 ./author/build-perl-al2.sh "$PERL_VERSION"

# check the perl binary works on the lambci/lambda:provided image
docker run -v "$OPT:/opt" -v "$ROOT/examples/hello:/var/task" --rm --entrypoint /opt/bin/perl lambci/lambda:provided.al2 -V

# create zip archive
cd "$OPT"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime-al2.zip" .
