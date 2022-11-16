FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git ca-certificates iproute2 can-utils jq sed wget tar gzip && \
    apt-get clean
WORKDIR /root
RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.25.0/crictl-v1.25.0-linux-arm64.tar.gz && \
    tar zxvf crictl-v1.25.0-linux-arm64.tar.gz -C /usr/local/bin

ENTRYPOINT ["tail", "-f", "/dev/null"]
