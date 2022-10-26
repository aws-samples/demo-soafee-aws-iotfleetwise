#!/bin/bash
kubectl delete pod fwe
kubectl delete svc vsim-svc
kubectl apply -f deploy.yml
kubectl wait --for=condition=ready pod -l app=bcw-demo

echo -n "Bringing up CAN bus..."
CRICTL="crictl -r unix:///run/k3s/containerd/containerd.sock"
PODID=$($CRICTL pods --name fwe -o json | jq -r '.items[0].id')
PID_FWE=$($CRICTL inspectp $PODID | jq -r '.info.pid')
#nsenter -t $PID_FWE -n ip link add dev vcan0 type vcan
#nsenter -t $PID_FWE -n ip link set vcan0 up
echo "done"

kubectl logs -f fwe -c fwe
