#!/usr/bin/env bash

# perlstrip off loaded to AWS Lambda

set -e

curl -sSf --upload-file "$1"  https://tsjax7b6xiykqv3zua6iankaia0ldqde.lambda-url.ap-northeast-1.on.aws/ -o "/tmp/perlstrip.$$"
mv -f "/tmp/perlstrip.$$" "$1"
