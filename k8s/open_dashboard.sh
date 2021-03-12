#!/bin/sh

. "$(dirname "$0")/kubectl.sh"

sudo $kubectl -n kubernetes-dashboard describe secret "$($kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')" | grep 'token:'

[ $? -eq 0 ] || exit 2

echo ""
xdg-open 'http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'

echo ""
sudo $kubectl proxy
