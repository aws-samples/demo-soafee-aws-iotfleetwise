#!/bin/bash
set -e
CAN_BUS0=$(cat .tmp/vehicle_can_interface.txt)
ENDPOINT_URL=$(cat .tmp/endpoint_address.txt)
VEHICLE_NAME=$(cat .tmp/vehicle_name.txt)
TRACE=off

trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    echo "cleaning up..."
    # Clean up
    sudo kubectl delete all --all
}

# Make sure secrets are there for key and cert
# kubectl create secret generic private-key --from-file=./.tmp/private-key.key
# kubectl create secret generic certificate --from-file=./.tmp/certificate.pem

# Deploy
sudo modprobe vcan
sudo kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: fwe
  labels:
    app: demo
spec:
  initContainers:
  - name: vcan
    image: public.ecr.aws/docker/library/alpine:3
    imagePullPolicy: IfNotPresent
    command: 
      - sh
      - -c
      - ip link add dev $CAN_BUS0 type vcan && ip link set $CAN_BUS0 up
    securityContext:
      privileged: true
      capabilities:
        add: ["CAP_NET_ADMIN"]
  containers:
  - name: fwe
    image: public.ecr.aws/aws-iot-fleetwise-edge/aws-iot-fleetwise-edge:v1.0.3
    imagePullPolicy: Always
    env:
    - name: CAN_BUS0
      value: "$CAN_BUS0"
    - name: ENDPOINT_URL
      value: "$ENDPOINT_URL"
    - name: VEHICLE_NAME
      value: "$VEHICLE_NAME"
    - name: TRACE
      value: "$TRACE"
    volumeMounts:
    - name: private-key
      mountPath: "/etc/aws-iot-fleetwise/private-key.key"
      subPath: private-key.key
      readOnly: true
    - name: certificate
      mountPath: "/etc/aws-iot-fleetwise/certificate.pem"
      subPath: certificate.pem
      readOnly: true
  - name: vsim
    image: docker.io/library/vsim:latest
    imagePullPolicy: Never
    env:
    - name: CAN_IF
      value: "$CAN_BUS0"
    ports:
    - containerPort: 3000
      hostPort: 8080
      protocol: TCP
  volumes:
  - name: private-key
    secret:
      secretName: private-key
      optional: false 
  - name: certificate
    secret:
      secretName: certificate
      optional: false 
EOF
sudo kubectl wait --for=condition=ready pod -l app=demo

# Show log from fwe
sudo kubectl logs -f fwe -c fwe
