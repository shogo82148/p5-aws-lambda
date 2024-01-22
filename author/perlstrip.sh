#!/usr/bin/env bash

# perlstrip off loaded to AWS Lambda

echo "stripping $1..." 2>&1
curl -sSf --upload-file "$1"  https://tsjax7b6xiykqv3zua6iankaia0ldqde.lambda-url.ap-northeast-1.on.aws/ -o "/tmp/perlstrip.$$" || exit 0
mv -f "/tmp/perlstrip.$$" "$1" || exit 0
