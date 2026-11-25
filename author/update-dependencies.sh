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

# update_cpanm FILE_NAME: pin the App-cpanminus release that cpanm is built from.
# CPANM_VERSION, CPANM_AUTHOR and CPANM_SHA256 come from one MetaCPAN release record and are
# written together, and only after a download from www.cpan.org matches that SHA-256.
function update_cpanm {
    local FILE_NAME=$1
    local RELEASE CPANM_VERSION CPANM_AUTHOR CPANM_SHA256 TARBALL ACTUAL
    RELEASE=$(curl --proto '=https' -fsSL "https://fastapi.metacpan.org/v1/release/App-cpanminus")
    CPANM_VERSION=$(jq -er '.version' <<< "$RELEASE")
    CPANM_AUTHOR=$(jq -er '.author' <<< "$RELEASE")
    CPANM_SHA256=$(jq -er '.checksum_sha256' <<< "$RELEASE")

    # these values are written into a shell script, so accept only the expected shapes
    if ! [[ $CPANM_VERSION =~ ^[0-9][0-9._]*$ && $CPANM_AUTHOR =~ ^[A-Z][A-Z0-9-]+$ && $CPANM_SHA256 =~ ^[0-9a-f]{64}$ ]]; then
        echo "unexpected App-cpanminus release: $CPANM_VERSION $CPANM_AUTHOR $CPANM_SHA256" >&2
        exit 1
    fi

    TARBALL=$(mktemp)
    curl --proto '=https' --proto-redir '=https' -fsSL -o "$TARBALL" \
        "https://www.cpan.org/authors/id/${CPANM_AUTHOR:0:1}/${CPANM_AUTHOR:0:2}/$CPANM_AUTHOR/App-cpanminus-$CPANM_VERSION.tar.gz"
    ACTUAL=$(shasum -a 256 "$TARBALL" | cut -d' ' -f1)
    rm -f "$TARBALL"
    if [ "$ACTUAL" != "$CPANM_SHA256" ]; then
        echo "SHA-256 mismatch for App-cpanminus-$CPANM_VERSION: MetaCPAN says $CPANM_SHA256, www.cpan.org served $ACTUAL" >&2
        exit 1
    fi

    echo "update App-cpanminus $FILE_NAME $CPANM_VERSION $CPANM_AUTHOR $CPANM_SHA256"
    CPANM_VERSION=$CPANM_VERSION CPANM_AUTHOR=$CPANM_AUTHOR CPANM_SHA256=$CPANM_SHA256 \
        perl -i -pe 's/^(CPANM_(?:VERSION|AUTHOR|SHA256))=.+$/$1=$ENV{$1}/' "$FILE_NAME"
}

update_cpanm build-perl-al2023.sh

update Paws PAWS_VERSION build-paws-al2023.sh
