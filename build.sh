#!/usr/bin/env bash

set -e

VERSION=${1}
MAKESELF_VERSION=${MAKESELF_VERSION:-"2.4.3"}
MAKESELF_INSTALL_DIR=$(mktemp -d makeself.XXXXXX)

check_version(){
    if [ -z "${VERSION}" ]; then
        warn "kubernetes version not specified, use default version 1.21.2."
        VERSION="1.21.2"
    fi
    IMAGE_LIST=$(kubeadm config images list --kubernetes-version v${VERSION})
}

check_makeself(){
    if ! command -v makeself.sh >/dev/null 2>&1; then
        wget -q https://github.com/megastep/makeself/releases/download/release-${MAKESELF_VERSION}/makeself-${MAKESELF_VERSION}.run
        bash makeself-${MAKESELF_VERSION}.run --target ${MAKESELF_INSTALL_DIR}
        export PATH=${MAKESELF_INSTALL_DIR}:${PATH}
    fi
}

download(){
    info "download kubernetes images..."
    for i in ${IMAGE_LIST[@]}; do
        info "download => [${i}]..."
        ctr images pull ${i}
    done
    ctr images export pack/kubeadm_v${VERSION}.tar ${IMAGE_LIST}
}

build(){
    info "building..."
    makeself.sh pack kubeadm-config_v${VERSION}.run "kubeadm-config" ./helper.sh kubeadm-config_v${VERSION}.run
}

clean(){
    info "clean files."
    rm -rf pack/bin/* makeself* ${MAKESELF_INSTALL_DIR} pack/*.tar
}

function info(){
    echo -e "\033[1;32mINFO: $@\033[0m"
}

function warn(){
    echo -e "\033[1;33mWARN: $@\033[0m"
}

function err(){
    echo -e "\033[1;31mERROR: $@\033[0m"
}

check_version
check_makeself
download
build
clean

