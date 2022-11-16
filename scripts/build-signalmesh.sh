#!/bin/bash

pushd signalmesh
tar -czh . | docker build -t signalmesh -
if [ -e /run/k3s/containerd/containerd.sock ]; then
docker save signalmesh:latest | ctr -a /run/k3s/containerd/containerd.sock -n=k8s.io images import -
fi
popd
