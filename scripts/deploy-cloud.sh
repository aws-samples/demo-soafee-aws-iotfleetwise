#!/bin/bash
sudo apt-get -y install jq gettext bash-completion moreutils
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a /home/ec2-user/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a /home/ec2-user/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure set default.account ${ACCOUNT_ID}
git config --global core.autocrlf false
cdk bootstrap aws://${ACCOUNT_ID}/${AWS_REGION}

mkdir -p .tmp
pushd cloud
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cdk deploy --require-approval never --outputs-file ../.tmp/cdk-outputs.json
popd
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".privateKey' > .tmp/private-key.key 
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".certificate' > .tmp/certificate.pem
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".endpointAddress'  > .tmp/endpoint_address.txt
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".vehicleCanInterface'  > .tmp/vehicle_can_interface.txt
cat .tmp/cdk-outputs.json | jq -r '."demo-soafee-aws-iotfleetwise".vehicleName'  > .tmp/vehicle_name.txt
