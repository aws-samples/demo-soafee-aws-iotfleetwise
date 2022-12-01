#!/bin/bash
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.UTF-8 >> /etc/environment
yum -y install jq gettext bash-completion moreutils
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
sudo -u ec2-user bash  << EOF
. /home/ec2-user/.bash_profile
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a /home/ec2-user/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a /home/ec2-user/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure set default.account ${ACCOUNT_ID}
cd /home/ec2-user/environment
git config --global core.autocrlf false
git clone https://github.com/aws-samples/demo-soafee-aws-iofleetwise.git
cdk bootstrap aws://${ACCOUNT_ID}/${AWS_REGION}
EOF
