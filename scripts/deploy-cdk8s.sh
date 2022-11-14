#!/bin/bash
export CAN_IF=$(cat .tmp/vehicle_can_interface.txt)
export FW_ENDPOINT=$(cat .tmp/endpoint_address.txt)
export VEHICLE_NAME=$(cat .tmp/vehicle_name.txt)
export TRACE=off

trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    echo "cleaning up..."
    # Clean up
    sudo kubectl delete all --all
    echo "done"
}

# Make sure secrets are there for key and cert
# kubectl create secret generic private-key --from-file=./.tmp/private-key.key
# kubectl create secret generic certificate --from-file=./.tmp/certificate.pem

# Deploy
pushd cdk8s
npm run build
popd
sudo kubectl apply -f cdk8s/dist/demo-soafee-aws-iotfleetwise.k8s.yaml
sudo kubectl wait --for=condition=ready pod -l app=demo-soafee-aws-iotfleetwise

# Show log from fwe
sudo kubectl logs -f -l app=demo-soafee-aws-iotfleetwise -c fwe
