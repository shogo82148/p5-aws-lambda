#!/bin/bash

ROOT=$(cd "$(dirname "$0")" && pwd)
EXITCODE=0

set -xu
for TEMPLATE in "$ROOT"/*.yml; do
    aws cloudformation validate-template --region ap-northeast-1 --template-body "file://${TEMPLATE}" || EXITCODE=1
done

exit "$EXITCODE"
