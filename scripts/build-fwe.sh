#!/bin/bash

pushd fwe
tar -czh . | docker build -t fwe -
if [ -e /run/k3s/containerd/containerd.sock ]; then
docker save fwe:latest | ctr -a /run/k3s/containerd/containerd.sock -n=k8s.io images import -
fi
popd
