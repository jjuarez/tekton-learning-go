#!/usr/bin/env bash

set -eu -o pipefail
#set -x

#
# ::main::
#
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --namespace=tekton-pipelines --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
kubectl apply --namespace=tekton-pipelines --filename ./tasks/git-clone.yaml
kubectl apply --namespace=tekton-pipelines --filename ./tasks/kaniko.yaml
kubectl create --namespace=tekton-pipelines secret docker-registry ghcr --docker-username=${GITHUB_USERNAME} --docker-password=${GITHUB_TOKEN} --docker-server="https://ghcr.io/v1"
kubectl apply --namespace=tekton-pipelines apply tekton-ci-sa.yaml
