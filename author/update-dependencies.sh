#!/bin/bash

set -eux

cd "$(dirname "$0")"

# release_field RELEASE_JSON FIELD MODULE: print FIELD of a MetaCPAN release, or exit if it is missing
function release_field {
    VALUE=$(jq -r ".$2" <<< "$1")
    if [ -z "$VALUE" ] || [ "$VALUE" = "null" ]; then
        echo "failed to get $2 for $3" >&2
        exit 1
    fi
    echo "$VALUE"
}

# write_pin NAME VALUE FILE_NAME: rewrite the NAME=... line in FILE_NAME
function write_pin {
    echo "update $1 $3 $2"
    VERSION_NAME=$1 VERSION=$2 perl -i -pe 's/^\Q$ENV{VERSION_NAME}\E=.+$/$ENV{VERSION_NAME}=$ENV{VERSION}/' "$3"
}

function update {
    MODULE=$1
    VERSION_NAME=$2
    FILE_NAME=$3
    RELEASE=$(curl -sSL "https://fastapi.metacpan.org/v1/release/$MODULE")
    VERSION=$(release_field "$RELEASE" version "$MODULE")
    write_pin "$VERSION_NAME" "$VERSION" "$FILE_NAME"
}

# update_paws FILE_NAME: PAWS_VERSION and PAWS_AUTHOR come from the same release
# and are both checked before either is written, so they never get out of sync.
function update_paws {
    FILE_NAME=$1
    RELEASE=$(curl -sSL "https://fastapi.metacpan.org/v1/release/Paws")
    VERSION=$(release_field "$RELEASE" version Paws)
    AUTHOR=$(release_field "$RELEASE" author Paws)
    write_pin PAWS_VERSION "$VERSION" "$FILE_NAME"
    write_pin PAWS_AUTHOR "$AUTHOR" "$FILE_NAME"
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
update local-lib LOCAL_LIB_VERSION build-perl-al2.sh

update Paws PAWS_VERSION build-paws-al2.sh


update Net-SSLeay NET_SSLEAY_VERSION build-perl-al2023.sh
update Carton CARTON_VERSION build-perl-al2023.sh
update AWS-XRay AWS_XRAY_VERSION build-perl-al2023.sh
update JSON JSON_VERSION build-perl-al2023.sh
update JSON-XS JSON_XS_VERSION build-perl-al2023.sh
update Cpanel-JSON-XS CPANEL_JSON_XS_VERSION build-perl-al2023.sh
update JSON-MaybeXS JSON_MAYBEXS_VERSION build-perl-al2023.sh
update YAML YAML_VERSION build-perl-al2023.sh
update YAML-Tiny YAML_TINY_VERSION build-perl-al2023.sh
update YAML-LibYAML YAML_XS_VERSION build-perl-al2023.sh
update IO-Socket-SSL IO_SOCKET_SSL_VERSION build-perl-al2023.sh
update Mozilla-CA MOZILLA_CA_VERSION build-perl-al2023.sh
update local-lib LOCAL_LIB_VERSION build-perl-al2023.sh

update_paws build-paws-al2023.sh
