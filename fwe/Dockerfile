FROM ubuntu:18.04

ENV container=docker LANG=C.UTF-8

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git ca-certificates iproute2 can-utils jq sed && \
    apt-get clean
WORKDIR /root
RUN git clone --depth 1 --branch v1.0.0 https://github.com/aws/aws-iot-fleetwise-edge.git && \
    cd /root/aws-iot-fleetwise-edge/ && \
    sed -i 's/sudo//g' ./tools/install-deps-native.sh && \
    ./tools/install-deps-native.sh && \
    ./tools/build-fwe-native.sh && \
    cp ./build/src/executionmanagement/aws-iot-fleetwise-edge /usr/bin/ && \
    cp ./tools/configure-fwe.sh /usr/bin && \
    cp ./configuration/static-config.json /etc/ && \
    apt-get clean && \
    cd /root && \
    rm -rf aws-iot-fleetwise-edge

ADD start-fwe.sh /usr/bin

CMD ["/bin/bash", "/usr/bin/start-fwe.sh"]
