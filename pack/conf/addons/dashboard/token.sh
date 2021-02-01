#!/usr/bin/env bash

set -e

kubectl -n kube-addons describe secret $(kubectl -n kube-addons get secret | grep k8s-admin | awk '{print $1}')
