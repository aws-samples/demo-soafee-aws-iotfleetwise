function ifup {
    typeset output
    output=$(ip link show "$1" up) && [[ -n $output ]]
}

while : ; do
    if ifup $CAN_IF; then
        break
    else
        echo "Waiting for $CAN_IF"
        sleep 3
    fi
done

mkdir -p /var/aws-iot-fleetwise
mkdir -p /etc/fwe
/usr/bin/configure-fwe.sh \
        --input-config-file /etc/static-config.json \
        --output-config-file /etc/aws-iot-fleetwise/config-0.json \
        --vehicle-name $VEHICLE_NAME \
        --endpoint-url $FW_ENDPOINT \
        --can-bus0 $CAN_IF 
#sed -i 's/Info/Trace/' /etc/aws-iot-fleetwise/config-0.json 
cat /etc/aws-iot-fleetwise/config-0.json
/usr/bin/aws-iot-fleetwise-edge /etc/aws-iot-fleetwise/config-0.json
#/usr/bin/candump $CAN_IF

