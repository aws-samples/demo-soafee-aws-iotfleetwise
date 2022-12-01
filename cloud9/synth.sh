#!/bin/bash
set -e

REGIONS="eu-central-1 us-east-1"

cdk synth -q
for region in $REGIONS
do
    aws s3 cp cdk.out/cloud9-env.template.json s3://demo-soafee-aws-iot-fleetwise-$region/
    aws s3api put-object-acl --bucket demo-soafee-aws-iot-fleetwise-$region --key cloud9-env.template.json --acl public-read
done

