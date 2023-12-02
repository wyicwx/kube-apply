#!/bin/bash

# 配置config
if [ -z $K8S_CONFIG ]; then
    echo $K8S_CONFIG > /root/.kube/config
fi

NAMESPACE_PROJECT=apps
kubectl -n $NAMESPACE_PROJECT --kubeconfig="/root/.kube/config" delete deploy,pods,services,ingress -l app=$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG