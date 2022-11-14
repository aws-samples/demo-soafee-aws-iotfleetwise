#!/bin/bash

# CAN_IF=vcan0
# FW_ENDPOINT=$(cat .tmp/endpoint.txt)
# VEHICLE_NAME=vin100
# TRACE=off

# # Clean up
# kubectl delete pod fwe
# kubectl delete svc vsim-svc
# kubectl delete ingress demo

# Make sure secrets are there for key and cert
# kubectl create secret generic private-key --from-file=./.tmp/private-key.key
# kubectl create secret generic certificate --from-file=./.tmp/certificate.pem

# Deploy
pushd k3s
npm run build
sudo kubectl delete all --all
sudo kubectl apply -f dist/demo-soafee-aws-iotfleetwise.k8s.yaml
popd
sudo kubectl wait --for=condition=ready pod -l name=demo-soafee-aws-iotfleetwise-pod-c8c5bdf0

# Show log from fwe
sudo kubectl logs -f demo-soafee-aws-iotfleetwise-pod-c8c5bdf0 -c fwe
