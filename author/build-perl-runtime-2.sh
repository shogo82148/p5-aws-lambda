#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.30.3 5-30
    exit 0
fi

PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/${PERL_VERSION}_2"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT"
mkdir -p "$OPT"
rm -f "$DIST/perl-$TAG-runtime-2.zip"

# build the perl binary
# TODO: replace lambci/lambda-base-2:build to amzn2 based build-provided image
docker run -v "$ROOT:/var/task" -v "$OPT:/opt" --rm lambci/lambda-base-2:build ./author/build-perl-2.sh "$PERL_VERSION"

# check the perl binary works on the lambci/lambda:provided image
# TODO: replace lambci/lambda:nodejs12.x to amzn2 based provided image
docker run -v "$OPT:/opt" -v "$ROOT/examples/hello:/var/task" --rm --entrypoint /opt/bin/perl lambci/lambda:nodejs12.x -V

# create zip archive
cd "$OPT"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime-2.zip" .
