#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)
PERL_VERSION=$1
OPT="$ROOT/.perl-layer/$PERL_VERSION"
set -ue

rm -rf "$OPT"
mkdir -p "$OPT"
docker run -v "$ROOT:/var/task" -v "$OPT:/opt" --rm lambci/lambda:build-provided ./author/build-perl.sh "$PERL_VERSION"
