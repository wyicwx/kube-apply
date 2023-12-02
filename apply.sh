#!/bin/sh

# 配置config
if [ -z $K8S_CONFIG ];then
    echo "缺少 K8S_CONFIG 变量！"
    exit 1
else
    mkdir -p /root/.kube
    echo "$K8S_CONFIG" > /root/.kube/config
fi

# 指定namespace
if [ -z $K8S_NAMESPACE ];then
    NAMESPACE_PROJECT="apps"
else
    if [ "$K8S_NAMESPACE" = "system" ];then
        echo "不允许操作system namespace"
        exit 1
    fi
    NAMESPACE_PROJECT=$K8S_NAMESPACE
fi

# 指定yaml文件目录
if [ -z $1 ];then
    if [ -z $K8S_YAML_PATH ];then
        echo "缺少 K8S_YAML_PATH 变量或脚本执行参数！[k8s配置目录]"
        exit 1
    fi
else
    K8S_YAML_PATH="$1"
fi

# 格式化文件路径
if echo "$K8S_YAML_PATH" | grep -q -E '/$';then
    K8S_YAML_PATH="$K8S_YAML_PATH"
else
    K8S_YAML_PATH="$K8S_YAML_PATH/"
fi

# YAML文件路径
YAML_PATH=$K8S_YAML_PATH*

if [ "$K8S_APPLY_MODE" = "kustomize" ];then
    echo "当前apply模式: kustomize"
    MODE="kustomize"
else
    echo "当前apply模式: yaml"
    MODE="yaml"
fi

# enssubst格式化文件
if [ $K8S_FILE_ENVSUBST ];then
    echo "配置文件 envsubst: true"
else
    echo "配置文件 envsubst: false"
fi

for FILE in $YAML_PATH
do
    if test -f $FILE
    then
        echo $FILE
        echo "-----------------"

        if [ $K8S_FILE_ENVSUBST ];then
            envsubst < $FILE > $FILE"_tmp"
            cat $FILE"_tmp" > $FILE
            rm $FILE"_tmp"
        fi

        cat $FILE

        echo ""
        echo "-----------------"
    fi
done

if [ "$MODE" = "kustomize" ];then
    kubectl -n $NAMESPACE_PROJECT --kubeconfig="/root/.kube/config" apply -k $K8S_YAML_PATH
else
    kubectl -n $NAMESPACE_PROJECT --kubeconfig="/root/.kube/config" apply -f $K8S_YAML_PATH
fi