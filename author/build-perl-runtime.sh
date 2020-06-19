#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.26.3 5-26
    $0 5.28.3 5-28
    $0 5.30.3 5-30
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
rm -f "$DIST/perl-$TAG-runtime.zip"

docker run -v "$ROOT:/var/task" -v "$OPT:/opt" --rm lambci/lambda:build-provided ./author/build-perl.sh "$PERL_VERSION"
cd "$OPT"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime.zip" .
