#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

set -ue

"$ROOT/author/validate-account.sh" || exit 2

for ZIP in "$ROOT"/.perl-layer/dist/perl-*-runtime.zip; do
    NAME=$(basename "$ZIP" .zip)
    PERLVERION=$(echo "$NAME" | cut -d- -f2,3 | sed -e 's/-/./')
    STACK="${PERLVERION//./-}"
    while read -r REGION; do
        aws --region "$REGION" cloudformation describe-stacks \
            --stack-name "lambda-$STACK-runtime" | jq -r .Stacks[0].Outputs[0].OutputValue
    done < "$ROOT/author/regions.txt"
done

for ZIP in "$ROOT"/.perl-layer/dist/perl-*-paws.zip; do
    NAME=$(basename "$ZIP" .zip)
    PERLVERION=$(echo "$NAME" | cut -d- -f2,3 | sed -e 's/-/./')
    STACK="${PERLVERION//./-}"
    while read -r REGION; do
        aws --region "$REGION" cloudformation describe-stacks \
            --stack-name "lambda-$STACK-paws" | jq -r .Stacks[0].Outputs[0].OutputValue
    done < "$ROOT/author/regions.txt"
done
