#!/usr/bin/env bash

set -e

INSTALL_CMD=$(which install)
CONFIG_PATH="/etc/kubernetes"
ADDONS_PATH="/etc/kubernetes/addons"
CONTAINERD_CONFIG="/etc/containerd/config.toml"
CRICTL_CONFIG="/etc/crictl.yaml"
# containerd will use the namespace to isolate resources, and cri will
# always use the "k8s.io" namespace in the implementation of containerd.
# see: https://github.com/containerd/containerd/blob/ccde82da2b46b0a4d4cf24576c2499288594df96/pkg/cri/constants/constants.go#L23
CTR_NAMESPACE="k8s.io"

function install(){
    info "install kubeadm config..."
    ${INSTALL_CMD} -o root -g root -m 0644 conf/kubeadm*.yaml ${CONFIG_PATH}

    info "install addons..."
    cp -r conf/addons ${ADDONS_PATH}
    chown -R root:root ${ADDONS_PATH}

    info "install containerd config..."
    ${INSTALL_CMD} -D -o root -g root -m 0644 conf/containerd.toml ${CONTAINERD_CONFIG}

    info "restart containerd..."
    systemctl restart containerd

    info "install crictl config..."
    ${INSTALL_CMD} -o root -g root -m 0644 conf/crictl.yaml ${CRICTL_CONFIG}
}

function uninstall(){
    info "remove kubeadm config..."
    rm -f ${CONFIG_PATH}/kubeadm*.yaml

    info "remove addons..."
    rm -rf ${ADDONS_PATH}

    info "remove containerd config..."
    rm -f ${CONTAINERD_CONFIG}

    info "restart containerd..."
    systemctl restart containerd

    info "remove crictl config..."
    rm -f ${CRICTL_CONFIG}
}

function load(){
    info "load oci images..."
    ctr -n ${CTR_NAMESPACE} images import kubeadm_*.tar
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

case "${2}" in
    "install")
        install
        if [ "${3}" == "--load" ]; then
            load
        fi
        ;;
    "uninstall")
        uninstall
        ;;
    "load")
        load
        ;;
    *)
        cat <<EOF

NAME:
    ${1} - kubeadm config tool

USAGE:
    ${1} command

AUTHOR:
    mritd <mritd@linux.com>

COMMANDS:
    install     Install kubeadm & containerd config
    uninstall   Remove kubeadm & containerd config
    load        Load kubernetes images

COPYRIGHT:
   Copyright (c) $(date "+%Y") mritd, All rights reserved.
EOF
    exit 0
        ;;
esac

