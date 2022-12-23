#!/usr/bin/env bash

set -eu -o pipefail
#set -x

#
# ::main::
#
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --namespace=tekton-pipelines --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
echo "kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097"
kubectl apply --namespace=tekton-pipelines --filename ./tasks/git-clone.yaml
kubectl apply --namespace=tekton-pipelines --filename ./tasks/kaniko.yaml
kubectl apply --namespace=tekton-pipelines --filename ./pipelines/ci.yaml
