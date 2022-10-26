#!/bin/bash

pushd vsim
docker build . -t vsim
docker save vsim:latest | ctr -a /run/k3s/containerd/containerd.sock -n=k8s.io images import -
popd
