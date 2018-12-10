#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)
PERL_VERSION=$1
TAG=$2
OPT="$ROOT/.perl-layer/$PERL_VERSION"
set -ue

# clean up
rm -rf "$OPT"
mkdir -p "$OPT"
rm -f "$ROOT/lambda-perl-layer-$TAG.zip"

docker run -v "$ROOT:/var/task" -v "$OPT:/opt" --rm lambci/lambda:build-provided ./author/build-perl.sh "$PERL_VERSION"
cd "$OPT"
zip -9 -r "$ROOT/lambda-perl-layer-$TAG.zip" .
