#!/bin/sh

export kubectl;

if command -v kubectl > /dev/null; then
    kubectl=kubectl
else
    # For remote kubectl command k3s doesn't require a running server
    if [ -z "$kubectl" ] && command -v k3s > /dev/null; then
        kubectl='k3s kubectl'
    fi
    if [ -z "$kubectl" ] && command -v microk8s > /dev/null; then
        kubectl='microk8s kubectl'
    fi

    if [ -n "$kubectl" ]; then
        alias kubectl="$kubectl"
    fi
fi

if [ -z "$kubectl" ]; then
    >&2 echo "Kubernetes not installed"
    exit 1
fi
