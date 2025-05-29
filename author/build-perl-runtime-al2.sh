#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

if [[ $# -eq 0 ]]; then
    $0 5.40.2 5-40 x86_64
    $0 5.40.2 5-40 arm64
    $0 5.38.4 5-38 x86_64
    $0 5.38.4 5-38 arm64
    exit 0
fi

PERL_VERSION=$1
TAG=$2
PLATFORM=$3

OPT="$ROOT/.perl-layer/${PERL_VERSION}.al2"
DIST="$ROOT/.perl-layer/dist"
set -uex

# clean up
rm -rf "$OPT-$PLATFORM"
mkdir -p "$OPT-$PLATFORM"
rm -f "$DIST/perl-$TAG-runtime-al2-$PLATFORM.zip"

DOCKER_PLATFORM=linux/unknown
case $PLATFORM in
    "x86_64") DOCKER_PLATFORM=linux/amd64;;
    "arm64") DOCKER_PLATFORM=linux/arm64;;
    *) echo "unknown platform: $PLATFORM";
    exit 1;;
esac

# build the perl binary
docker run \
    -v "$ROOT:/var/task" \
    -v "$OPT-$PLATFORM:/opt" \
    --rm --platform "$DOCKER_PLATFORM" \
    "public.ecr.aws/sam/build-provided.al2:1-$PLATFORM" \
    ./author/build-perl-al2.sh "$PERL_VERSION"

# sanity check the perl binary works on the emulation images
docker run \
    -v "$OPT-$PLATFORM:/opt" \
    --rm --platform "$DOCKER_PLATFORM" \
    --entrypoint /opt/bin/perl \
    "public.ecr.aws/lambda/provided:al2-$PLATFORM" \
    -MJSON::XS -MYAML::XS -MNet::SSLeay -MIO::Socket::SSL -MMozilla::CA \
    -MAWS::XRay -MAWS::Lambda -MAWS::Lambda::PSGI -e ''

# create zip archive
cd "$OPT-$PLATFORM"
mkdir -p "$DIST"
zip -9 -r "$DIST/perl-$TAG-runtime-al2-$PLATFORM.zip" .
