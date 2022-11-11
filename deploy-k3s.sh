#!/bin/bash

CAN_IF=vcan0
FW_ENDPOINT="a1q6dgk6qorfqj-ats.iot.eu-central-1.amazonaws.com"
VEHICLE_NAME=vin200
TRACE=off

# Clean up
kubectl delete pod fwe
kubectl delete svc vsim-svc
kubectl delete ingress bcw-demo

# Make sure secrets are there for key and cert
#
# kubectl create secret generic private-key --from-file=./private-key.key
# kubectl create secret generic certificate --from-file=./certificate.pem

# Deploy
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: fwe
  labels:
    app: bcw-demo
spec:
  containers:
  - name: fwe
    image: ghcr.io/fsalamida/aws-iot-fleetwise-edge:feature-publish_container_image  
    env:
    - name: CAN_IF
      value: "$CAN_IF"
    - name: FW_ENDPOINT
      value: "$FW_ENDPOINT"
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
      value: "vcan0"
    ports:
    - containerPort: 3000
      protocol: TCP
  - name: vcan
    image: alpine:3
    imagePullPolicy: IfNotPresent
    command: ["/bin/sh","-c"]
    args: ["ip link add dev $CAN_IF type vcan && ip link set $CAN_IF up; tail -f /dev/null"]
    securityContext:
      privileged: true
      capabilities:
        add: ["CAP_NET_ADMIN"]
  volumes:
  - name: private-key
    secret:
      secretName: private-key
      optional: false 
  - name: certificate
    secret:
      secretName: certificate
      optional: false 
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: bcw-demo
  name: vsim-svc
spec:
  selector:
    app: bcw-demo
  ports:
  - protocol: TCP
    port: 3000
---
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: bcw-demo
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: vsim-svc
                port:
                  number: 3000
EOF
kubectl wait --for=condition=ready pod -l app=bcw-demo

# Show log from fwe
kubectl logs -f fwe -c fwe