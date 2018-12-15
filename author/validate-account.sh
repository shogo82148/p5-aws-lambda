#!/usr/bin/env bash

set -xue

AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)

if [[ "$AWS_ACCOUNT" != 445285296882 ]]; then
    echo "Invalid AWS Account: $AWS_ACCOUNT" > /dev/stderr
    exit 2
fi
