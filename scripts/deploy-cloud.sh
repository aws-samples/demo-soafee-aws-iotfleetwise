#!/bin/bash
set -euo pipefail

# Wait for any existing package install to finish
i=0
while true; do
    if sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; then
        i=0
    else
        i=`expr $i + 1`
        if expr $i \>= 10 > /dev/null; then
            break
        fi
    fi
    sleep 1
done


sudo apt-get -y update
sudo apt install python3.7
sudo apt install python3.7-venv
sudo apt-get -y update
sudo apt-get -y install jq gettext bash-completion moreutils linux-modules-extra-$(uname -r)
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a /home/ubuntu/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a /home/ubuntu/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure set default.account ${ACCOUNT_ID}
git config --global core.autocrlf false
cdk bootstrap aws://${ACCOUNT_ID}/${AWS_REGION}

mkdir -p .tmp
pushd cloud
python3.7 -m pip install --upgrade pip
python3.7 -m pip install --upgrade virtualenv
python3.7 --version
python3.7 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cdk deploy --require-approval never --outputs-file ../.tmp/cdk-outputs.json
popd
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".privateKey' > .tmp/private-key.key 
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".certificate' > .tmp/certificate.pem
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".endpointAddress'  > .tmp/endpoint_address.txt
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".vehicleCanInterface'  > .tmp/vehicle_can_interface.txt
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".vehicleName'  > .tmp/vehicle_name.txt
