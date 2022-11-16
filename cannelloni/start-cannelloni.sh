#!/bin/bash
function ifup {
    typeset output
    output=$(ip link show "$1" up) && [[ -n $output ]]
}

if [[ -z "$CAN_IF" ]]; then
    echo "Must provide CAN_IF in environment" 1>&2
    exit 1
fi

if [[ -z "$REMOTE_IP" ]]; then
    echo "Must provide REMOTE_IP in environment" 1>&2
    exit 1
fi

if [[ -z "$LOCAL_PORT" ]]; then
    echo "Must provide LOCAL_PORT in environment" 1>&2
    exit 1
fi

if [[ -z "$REMOTE_PORT" ]]; then
    echo "Must provide REMOTE_PORT in environment" 1>&2
    exit 1
fi

if ifup $CAN_IF; then
    echo "interface is up"
else 
    ip link add name $CAN_IF type vcan
    ip link set dev $CAN_IF up
fi

/usr/local/bin/cannelloni -I $CAN_IF -R $REMOTE_IP -r $REMOTE_PORT -l $LOCAL_PORT


