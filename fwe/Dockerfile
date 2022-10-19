FROM ubuntu:18.04

ENV container=docker LANG=C.UTF-8

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git ca-certificates iproute2 && \
    apt-get clean
WORKDIR /root
RUN git clone --depth 1 --branch v1.0.0 https://github.com/aws/aws-iot-fleetwise-edge.git
WORKDIR /root/aws-iot-fleetwise-edge/
RUN sed -i 's/sudo//g' ./tools/install-deps-native.sh && ./tools/install-deps-native.sh
RUN ./tools/build-fwe-native.sh
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git can-utils jq sed && \
    apt-get clean
RUN cp ./build/src/executionmanagement/aws-iot-fleetwise-edge /usr/bin/
ADD start-fwe.sh /usr/bin
#RUN mkdir -p /etc/aws-iot-fleetwise/ && \
#    touch /etc/aws-iot-fleetwise/certificate.pem && \
#    touch /etc/aws-iot-fleetwise/private-key.key

CMD ["/bin/bash", "/usr/bin/start-fwe.sh"]
