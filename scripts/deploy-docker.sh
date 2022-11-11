#!/bin/bash

echo -n "Cleaning up..."
docker kill $(docker ps -q) > /dev/null 2>&1
docker rm $(docker ps -aq) > /dev/null 2>&1
ip link delete vcan0 > /dev/null 2>&1
echo "done"

echo -n "Starting fwe container..."
docker run -d \
       -e CAN_IF=vcan0 \
       -e FW_ENDPOINT=$(jq -r '."demo-soafee-aws-iotfleetwise".endpointaddress' .tmp/cdk-outputs.json ) \
       -e VEHICLE_NAME=vin100 \
       -e TRACE=off \
       --mount type=bind,source=$(pwd)/.tmp/private-key.key,target=/etc/aws-iot-fleetwise/private-key.key,readonly \
       --mount type=bind,source=$(pwd)/.tmp/certificate.pem,target=/etc/aws-iot-fleetwise/certificate.pem,readonly \
       -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
       --tmpfs /tmp \
       --tmpfs /run \
       --tmpfs /run/lock \
       --name fwe \
       fwe  
echo "done"

echo -n "Starting vsim container..."
docker run -d \
       -e CAN_IF=vcan1 \
       -p 3000:3000 \
       --name vsim \
       vsim
echo "done"
  
echo -n "Bringing up CAN bus..."
DOCKERPID_FWE=$(docker inspect -f '{{ .State.Pid }}' fwe)
DOCKERPID_VSIM=$(docker inspect -f '{{ .State.Pid }}' vsim)
ip link add vcan0 type vxcan peer name vcan1
ip link set vcan0 netns $DOCKERPID_FWE
ip link set vcan1 netns $DOCKERPID_VSIM
nsenter -t $DOCKERPID_FWE -n ip link set vcan0 up
nsenter -t $DOCKERPID_VSIM -n ip link set vcan1 up
echo "done"

echo "Press CTRL+C to exit"
echo "---"
docker logs -f fwe
