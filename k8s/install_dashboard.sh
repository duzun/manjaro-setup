#!/bin/sh

. "$(dirname "$0")/kubectl.sh"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl apply -f dashboard-adminuser.yaml
