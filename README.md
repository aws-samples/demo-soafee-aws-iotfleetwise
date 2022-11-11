# Welcome to the SOAFEE AWS IoT Fleetwise demo

This demo aims to exhibit how [AWS IoT Fleetwise](https://aws.amazon.com/iot-fleetwise) can be deployied in a container and how the same image can be used for a virtual and physical target. The target would run SOAFEE OS reference implementation [EWAOL](https://github.com/aws4embeddedlinux/meta-aws-ewaol).

## Getting started

Clone this repository and issue the following commands to bootstrap cdk in your default aws profile account/region. 
> :warning: **At the time of writing, AWS Iot FleetWise is only available in preview only in us-east-1 and eu-central-1 so be sure to use one of the mentioned region to run the demo on**

If CDK cli is not installed please do the following

```sh
npm install -g aws-cdk
npx cdk bootstrap --cloudformation-execution-policies \
  arn:aws:iam::aws:policy/AdministratorAccess 
```

Run the following script to deploy the cdk stack

```sh
./script/deploy-cloud.sh
```

### The following steps NEED to be detailed. This is a working in progress
----
 
- Create an EC2 instance using EWAOL AMI
- Copy .tmp directory to the instance
- Ssh to the new instance and clone this repository
- Execute the following to build the conatiner images
```sh
./script/build-fwe.sh
./script/build-vsim.sh
```
- Load certificate and key into k3s secrets
```sh
kubectl create secret generic private-key --from-file=./.tmp/private-key.key
kubectl create secret generic certificate --from-file=./.tmp/certificate.pem
```
- Execute the following to deploy to k3s
```sh
./script/deploy-k3s.sh
```
- Run the following command on your PC
```sh
ssh -N -L 3000:localhost:3000 ewaol@<ewaol_ip_address>
```
- Open browser to http://localhost:3000
