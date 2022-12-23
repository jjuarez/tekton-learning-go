#!/usr/bin/env bash

set -eu -o pipefail
#set -x

#
# ::main::
#
kind create cluster --config tekton-playground-cluster.yaml
kubectl apply  --filename ./ns/tekton-pipelines-ns.yaml
kubectl create --namespace=tekton-pipelines secret docker-registry ghrc --docker-username=${GITHUB_USERNAME} --docker-password=${GITHUB_TOKEN} --docker-server="https://ghcr.io/v1"
kubectl apply  --namespace=tekton-pipelines --filename ./sa/tekton-ci-sa.yaml
