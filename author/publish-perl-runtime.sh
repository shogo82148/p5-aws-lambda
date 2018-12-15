#!/usr/bin/env bash

ROOT=$(cd "$(dirname "$0")/../" && pwd)

set -ue

"$ROOT/author/validate-account.sh" || exit 2

for ZIP in "$ROOT"/.perl-layer/dist/*.zip; do
    MD5=$(openssl dgst -md5 -binary "$ZIP" | openssl enc -base64)
    NAME=$(basename "$ZIP" .zip)
    PERLVERION=$(echo "$NAME" | cut -d- -f2 | sed -e 's/-/./')
    STACK=$(echo "$NAME" | cut -d- -f2)
    while read -r REGION; do
        # Upload zip file
        OBJECT=$(aws --output json --region "$REGION" \
            s3api head-object --bucket "shogo82148-lambda-perl-runtime-$REGION" \
            --key "$(basename "$ZIP")" || echo '{}')
        if [[ "$(echo "$OBJECT" | jq -r .Metadata.md5chksum)" != "$MD5" ]]; then
            echo Uploading "$(basename "$ZIP")" to "shogo82148-lambda-perl-runtime-$REGION"
            OBJECT=$(aws --output json --region "$REGION" \
                s3api put-object --bucket "shogo82148-lambda-perl-runtime-$REGION" \
                --acl public-read --key "$(basename "$ZIP")" --body "$ZIP" \
                --content-md5 "$MD5" --metadata md5chksum="$MD5")
        else
            echo "$(basename "$ZIP")" in "shogo82148-lambda-perl-runtime-$REGION" is already updated
        fi
        echo updating stack in "$REGION"...
        VERSION=$(echo "$OBJECT" | jq -r .VersionId)
        aws --region "$REGION" cloudformation deploy \
            --stack-name "lambda-$STACK-runtime" \
            --template-file "$ROOT/author/cfn-layer.yml" \
            --parameter-overrides "PerlVersion=$PERLVERION" "Name=$NAME" "ObjectVersion=$VERSION" \
            || true
        echo updated stack in "$REGION"
    done < "$ROOT/author/regions.txt"
done

echo
echo ARNS
for ZIP in "$ROOT"/.perl-layer/dist/*.zip; do
    STACK="${PERLVERION//./-}"
    while read -r REGION; do
        aws --region "$REGION" cloudformation describe-stacks \
            --stack-name "lambda-$STACK-runtime" | jq -r .Stacks[0].Outputs[0].OutputValue
    done < "$ROOT/author/regions.txt"
done
