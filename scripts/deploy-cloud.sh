#!/bin/bash

mkdir -p .tmp
pushd cloud
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cdk deploy --outputs-file ../.tmp/cdk-outputs.json
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".privatekey' > .tmp/private-key.key 
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".certificate' > .tmp/certificate.pem
popd