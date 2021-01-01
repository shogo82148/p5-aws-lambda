#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")" && pwd)

set -xue

"$ROOT/validate-account.sh" || exit 2

aws --region "ap-northeast-1" cloudformation deploy \
    --stack-name "lambda-perl5-runtime-ecr" \
    --capabilities CAPABILITY_IAM \
    --template-file "${ROOT}/cfn-ecr.yml"
