#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")" && pwd)

set -xue

"$ROOT/validate-account.sh" || exit 2

while read -r REGION; do
aws --region "$REGION" cloudformation deploy \
    --stack-name "lambda-perl5-runtime-s3" \
    --template-file "${ROOT}/cfn-s3.yml" || true
done < "$ROOT/regions.txt"
