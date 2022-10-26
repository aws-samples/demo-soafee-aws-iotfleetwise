function ifup {
    typeset output
    output=$(ip link show "$1" up) && [[ -n $output ]]
}

ip link add dev $CAN_IF type vcan
ip link set $CAN_IF up

while : ; do
    if ifup $CAN_IF; then
        break
    else
        echo "Waiting for $CAN_IF"
        sleep 3
    fi
done

gunicorn -b :3000 api:app