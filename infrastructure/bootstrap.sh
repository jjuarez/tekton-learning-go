#!/usr/bin/env bash

set -eu -o pipefail
#set -x

#
# ::main::
#
kind create cluster --config tekton-playground-cluster.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --namespace=tekton-pipelines --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
kubectl create -n tekton-pipelines secret docker-registry ghrc --docker-username="${GITHUB_USERNAME}" --docker-password="${GITHUB_TOKEN}" --docker-server="https://ghcr.io/v1"
kubectl apply -n tekton-pipelines --filename ./tekton-ci-sa.yaml
kubectl apply -n tekton-pipelines --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
