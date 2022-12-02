#!/bin/bash
CAN_BUS0=$(cat .tmp/vehicle_can_interface.txt)
ENDPOINT_URL=$(cat .tmp/endpoint_address.txt)
VEHICLE_NAME=$(cat .tmp/vehicle_name.txt)

trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    echo "cleaning up..."
    # Clean up
    echo -n "Cleaning up..."
    docker kill $(docker ps -q) > /dev/null 2>&1
    docker rm $(docker ps -aq) > /dev/null 2>&1
    ip link delete $CAN_BUS0 > /dev/null 2>&1
    echo "done"
}


echo -n "Starting fwe container..."
docker run -d \
       -e CAN_BUS0=$CAN_BUS0 \
       -e ENDPOINT_URL=$ENDPOINT_URL \
       -e VEHICLE_NAME=$VEHICLE_NAME \
       -e TRACE=off \
       --mount type=bind,source=$(pwd)/.tmp/private-key.key,target=/etc/aws-iot-fleetwise/private-key.key,readonly \
       --mount type=bind,source=$(pwd)/.tmp/certificate.pem,target=/etc/aws-iot-fleetwise/certificate.pem,readonly \
       -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
       --tmpfs /tmp \
       --tmpfs /run \
       --tmpfs /run/lock \
       --name fwe \
       public.ecr.aws/aws-iot-fleetwise-edge/aws-iot-fleetwise-edge:v0.1.36  
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
ip link add $CAN_BUS0 type vxcan peer name vcansim
ip link set $CAN_BUS0 netns $DOCKERPID_FWE
ip link set vcansim netns $DOCKERPID_VSIM
nsenter -t $DOCKERPID_FWE -n ip link set $CAN_BUS0 up
nsenter -t $DOCKERPID_VSIM -n ip link set vcansim up
echo "done"

echo "Press CTRL+C to exit"
echo "---"
docker logs -f fwe
