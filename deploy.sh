#!/bin/bash

echo -n "Cleaning up..."
docker kill $(docker ps -q) > /dev/null 2>&1
docker rm $(docker ps -aq) > /dev/null 2>&1
ip link delete vxcan0 > /dev/null 2>&1
echo "done"

echo -n "Building and starting fwe container..."
pushd fwe
docker build . -t fwe
popd
docker run -d \
       -e CAN_IF=vxcan1 \
       -e FW_ENDPOINT=a1q6dgk6qorfqj-ats.iot.eu-central-1.amazonaws.com \
       -e VEHICLE_NAME=vin200 \
       --mount type=bind,source=$(pwd)/private-key.key,target=/etc/aws-iot-fleetwise/private-key.key,readonly \
       --mount type=bind,source=$(pwd)/certificate.pem,target=/etc/aws-iot-fleetwise/certificate.pem,readonly \
       -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
       --tmpfs /tmp \
       --tmpfs /run \
       --tmpfs /run/lock \
       --name fwe \
       fwe  
echo "done"

echo -n "Starting vsim container..."
pushd vsim
docker build . -t vsim
popd
docker run -d \
       -e CAN_IF=vxcan0 \
       -p 80:3000 \
       --name vsim \
       vsim
echo "done"
  
echo -n "Bringing up CAN bus..."
DOCKERPID_FWE=$(docker inspect -f '{{ .State.Pid }}' fwe)
DOCKERPID_VSIM=$(docker inspect -f '{{ .State.Pid }}' vsim)
ip link add vxcan0 type vxcan peer name vxcan1
ip link set vxcan0 netns $DOCKERPID_VSIM
ip link set vxcan1 netns $DOCKERPID_FWE
nsenter -t $DOCKERPID_VSIM -n ip link set vxcan0 up
nsenter -t $DOCKERPID_FWE -n ip link set vxcan1 up
echo "done"

echo "Press CTRL+C to exit"
echo "---"
docker logs -f fwe
