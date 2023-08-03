#!/bin/bash

set -eux

cd "$(dirname "$0")"

function update {
    MODULE=$1
    VERSION_NAME=$2
    FILE_NAME=$3
    VERSION=$(curl -sSL "https://fastapi.metacpan.org/v1/release/$MODULE" | jq -r '.version')

    echo "update $MODULE $VERSION_NAME $FILE_NAME $VERSION"

    export VERSION_NAME
    export VERSION
    perl -i -pe 's/^\Q$ENV{VERSION_NAME}\E=.+$/$ENV{VERSION_NAME}=$ENV{VERSION}/' "$FILE_NAME"
}

update Net-SSLeay NET_SSLEAY_VERSION build-perl-al2.sh
update Carton CARTON_VERSION build-perl-al2.sh
update AWS-XRay AWS_XRAY_VERSION build-perl-al2.sh
update JSON JSON_VERSION build-perl-al2.sh
update JSON-XS JSON_XS_VERSION build-perl-al2.sh
update Cpanel-JSON-XS CPANEL_JSON_XS_VERSION build-perl-al2.sh
update JSON-MaybeXS JSON_MAYBEXS_VERSION build-perl-al2.sh
update YAML YAML_VERSION build-perl-al2.sh
update YAML-Tiny YAML_TINY_VERSION build-perl-al2.sh
update YAML-LibYAML YAML_XS_VERSION build-perl-al2.sh
update IO-Socket-SSL IO_SOCKET_SSL_VERSION build-perl-al2.sh
update Mozilla-CA MOZILLA_CA_VERSION build-perl-al2.sh

update Paws PAWS_VERSION build-paws-al2.sh
