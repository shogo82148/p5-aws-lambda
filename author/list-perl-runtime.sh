#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

"$ROOT/author/validate-account.sh" || exit 2

set -ue

for ZIP in $(find "$ROOT"/.perl-layer/dist -name perl-\*-runtime.zip | sort -r); do
    NAME=$(basename "$ZIP" .zip)
    PERLVERION=$(echo "$NAME" | cut -d- -f2,3 | sed -e 's/-/./')
    STACK="${PERLVERION//./-}"
    echo "=item Perl $PERLVERION"
    echo
    echo "=over"
    echo
    while read -r REGION; do
        ARN=$(aws --region "$REGION" cloudformation describe-stacks \
            --stack-name "lambda-$STACK-runtime" | jq -r .Stacks[0].Outputs[0].OutputValue)
        echo "=item C<$ARN>"
        echo
    done < "$ROOT/author/regions.txt"
    echo "=back"
    echo
done

for ZIP in $(find "$ROOT"/.perl-layer/dist -name perl-\*-paws.zip | sort -r); do
    NAME=$(basename "$ZIP" .zip)
    PERLVERION=$(echo "$NAME" | cut -d- -f2,3 | sed -e 's/-/./')
    STACK="${PERLVERION//./-}"
    echo "=item Perl $PERLVERION"
    echo
    echo "=over"
    echo
    while read -r REGION; do
        ARN=$(aws --region "$REGION" cloudformation describe-stacks \
            --stack-name "lambda-$STACK-paws" | jq -r .Stacks[0].Outputs[0].OutputValue)
        echo "=item C<$ARN>"
        echo
    done < "$ROOT/author/regions.txt"
    echo "=back"
    echo
done
