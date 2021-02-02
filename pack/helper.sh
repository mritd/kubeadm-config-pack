#!/usr/bin/env bash

set -e

INSTALL_CMD=$(which install)
CONFIG_PATH="/etc/kubernetes/kubeadm.yaml"
ADDONS_PATH="/etc/kubernetes/addons"
CONTAINERD_CONFIG_PATH="/etc/containerd/config.toml"
CRICTL_CONFIG="/etc/crictl.yaml"

function install(){
    info "install kubeadm config..."
    ${INSTALL_CMD} -o root -g root -m 0644 conf/kubeadm.yaml ${CONFIG_PATH}

    info "install addons..."
    cp -r conf/addons ${ADDONS_PATH}
    find ${ADDONS_PATH} -type d -exec chmod 0755 {} \;
    find ${ADDONS_PATH} -type f -exec chmod 0644 {} \;
    chown -R root:root ${ADDONS_PATH}

    info "install containerd config..."
    ${INSTALL_CMD} -D -o root -g root -m 0644 conf/containerd.toml ${CONTAINERD_CONFIG_PATH}

    info "restart containerd..."
    systemctl restart containerd

    info "install crictl config..."
    ${INSTALL_CMD} -o root -g root -m 0644 conf/crictl.yaml ${CRICTL_CONFIG}
}

function uninstall(){
    info "remove kubeadm config..."
    rm -f ${CONFIG_PATH}

    info "remove addons..."
    rm -rf ${ADDONS_PATH}

    info "remove containerd config..."
    rm -f ${CONTAINERD_CONFIG_PATH}

    info "restart containerd..."
    systemctl restart containerd

    info "remove crictl config..."
    rm -f ${CRICTL_CONFIG}
}

function load(){
    info "load oci images..."
    ctr images import kubeadm_*.tar
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

