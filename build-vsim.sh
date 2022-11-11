#!/bin/bash

pushd vsim
tar -czh . | docker build -t vsim -
if [ -f /run/k3s/containerd/containerd.sock ]; then
docker save vsim:latest | ctr -a /run/k3s/containerd/containerd.sock -n=k8s.io images import -
fi
popd
