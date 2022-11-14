#!/bin/bash
CAN_IF=$(cat .tmp/vehicle_can_interface.txt)
FW_ENDPOINT=$(cat .tmp/endpoint_address.txt)
VEHICLE_NAME=$(cat .tmp/vehicle_name.txt)

trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    echo "cleaning up..."
    # Clean up
    echo -n "Cleaning up..."
    docker kill $(docker ps -q) > /dev/null 2>&1
    docker rm $(docker ps -aq) > /dev/null 2>&1
    ip link delete $CAN_IF > /dev/null 2>&1
    echo "done"
}


echo -n "Starting fwe container..."
docker run -d \
       -e CAN_IF=$CAN_IF \
       -e FW_ENDPOINT=$FW_ENDPOINT \
       -e VEHICLE_NAME=$VEHICLE_NAME \
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
       -e CAN_IF=vcansim \
       -p 3000:3000 \
       --name vsim \
       vsim
echo "done"
  
echo -n "Bringing up CAN bus..."
DOCKERPID_FWE=$(docker inspect -f '{{ .State.Pid }}' fwe)
DOCKERPID_VSIM=$(docker inspect -f '{{ .State.Pid }}' vsim)
ip link add $CAN_IF type vxcan peer name vcansim
ip link set $CAN_IF netns $DOCKERPID_FWE
ip link set vcansim netns $DOCKERPID_VSIM
nsenter -t $DOCKERPID_FWE -n ip link set $CAN_IF up
nsenter -t $DOCKERPID_VSIM -n ip link set vcansim up
echo "done"

echo "Press CTRL+C to exit"
echo "---"
docker logs -f fwe
