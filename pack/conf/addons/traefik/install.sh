#!/usr/bin/env bash

set -e

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install --values=./custom-values.yml --namespace=kube-addons traefik traefik/traefik
