#!/bin/bash

pushd cannelloni
tar -czh . | docker build -t cannelloni -
if [ -e /run/k3s/containerd/containerd.sock ]; then
docker save fwe:latest | ctr -a /run/k3s/containerd/containerd.sock -n=k8s.io images import -
fi
# aws ecr describe-repositories --repository-names fwe > /dev/null 2>&1 || aws ecr create-repository --repository-name fwe
# aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 642733357784.dkr.ecr.eu-central-1.amazonaws.com
# docker tag fwe:latest 642733357784.dkr.ecr.eu-central-1.amazonaws.com/fwe:latest
# docker push 642733357784.dkr.ecr.eu-central-1.amazonaws.com/fwe:latest
popd
