#!/bin/bash

kubectl delete pod fwe

kubectl apply -f deploy.yml


kubectl wait --for=condition=ready pod -l app=bcw-demo
kubectl logs -f fwe

#CID=$(kubectl get pod fwe -o jsonpath='{.status.containerStatuses[].containerID}' | tr -d containerd://)

#crictl inspect -o go-template --template '{{ .info.pid }}' $CID
