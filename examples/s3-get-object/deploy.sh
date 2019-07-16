#!/bin/bash

set -eux

ROOT=$(cd "$(dirname "$0")" && pwd)
BUCKET=$1
STACK=$2
PREFIX=$3

aws cloudformation package \
    --template-file "$ROOT/template.yaml" \
    --output-template-file "$ROOT/packaged.yaml" \
    --s3-bucket "$BUCKET"

aws cloudformation deploy \
    --stack-name "$STACK" \
    --template "$ROOT/packaged.yaml" \
    --parameter-overrides "BucketNamePrefix=$PREFIX"\
    --capabilities CAPABILITY_IAM
