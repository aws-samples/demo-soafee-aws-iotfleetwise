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

---

This package depends on and may incorporate or retrieve a number of third-party
software packages (such as open source packages) at install-time or build-time
or run-time ("External Dependencies"). The External Dependencies are subject to
license terms that you must accept in order to use this package. If you do not
accept all of the applicable license terms, you should not use this package. We
recommend that you consult your company’s open source approval policy before
proceeding.

Provided below is a list of External Dependencies and the applicable license
identification as indicated by the documentation associated with the External
Dependencies as of Amazon's most recent review.

THIS INFORMATION IS PROVIDED FOR CONVENIENCE ONLY. AMAZON DOES NOT PROMISE THAT
THE LIST OR THE APPLICABLE TERMS AND CONDITIONS ARE COMPLETE, ACCURATE, OR
UP-TO-DATE, AND AMAZON WILL HAVE NO LIABILITY FOR ANY INACCURACIES. YOU SHOULD
CONSULT THE DOWNLOAD SITES FOR THE EXTERNAL DEPENDENCIES FOR THE MOST COMPLETE
AND UP-TO-DATE LICENSING INFORMATION.

YOUR USE OF THE EXTERNAL DEPENDENCIES IS AT YOUR SOLE RISK. IN NO EVENT WILL
AMAZON BE LIABLE FOR ANY DAMAGES, INCLUDING WITHOUT LIMITATION ANY DIRECT,
INDIRECT, CONSEQUENTIAL, SPECIAL, INCIDENTAL, OR PUNITIVE DAMAGES (INCLUDING
FOR ANY LOSS OF GOODWILL, BUSINESS INTERRUPTION, LOST PROFITS OR DATA, OR
COMPUTER FAILURE OR MALFUNCTION) ARISING FROM OR RELATING TO THE EXTERNAL
DEPENDENCIES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, EVEN
IF AMAZON HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. THESE LIMITATIONS
AND DISCLAIMERS APPLY EXCEPT TO THE EXTENT PROHIBITED BY APPLICABLE LAW.


vsim/Dockerfile depends on third party **docker/library/node** container image, please refer to [license section](https://gallery.ecr.aws/docker/library/node) 

vsim/Dockerfile depends on third party **docker/library/python** container image, please refer to [license section](https://gallery.ecr.aws/docker/library/python) 