#!/bin/bash

mkdir -p .tmp
pushd cloud
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cdk deploy --outputs-file ../.tmp/cdk-outputs.json
popd
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".privateKey' > .tmp/private-key.key 
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".certificate' > .tmp/certificate.pem
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".endpointAddress'  > .tmp/endpoint_address.txt
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".vehicleCanInterface'  > .tmp/vehicle_can_interface.txt
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".vehicleName'  > .tmp/vehicle_name.txt
