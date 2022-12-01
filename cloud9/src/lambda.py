from __future__ import print_function
import boto3
import json
import os
import time
import traceback
import cfnresponse

def on_event(event, context):
    print('event: {}'.format(event))
    print('context: {}'.format(context))
    responseData = {}

    if event['RequestType'] == 'Create':
        try:
            # Open AWS clients
            ec2 = boto3.client('ec2')

            # Get the InstanceId of the Cloud9 IDE
            print(ec2.describe_instances(Filters=[{'Name': 'tag:SSMBootstrap','Values': ['Active']}]))
            instance = ec2.describe_instances(
                    Filters=[
                        {'Name': 'tag:SSMBootstrap','Values': ['Active']},
                        {'Name': 'instance-state-name','Values': ['pending', 'running']}
                    ]
                )['Reservations'][0]['Instances'][0]
            print('instance: {}'.format(instance))

            # Create the IamInstanceProfile request object
            iam_instance_profile = {
                'Arn': event['ResourceProperties']['InstanceProfileArn'],
                'Name': event['ResourceProperties']['InstanceProfileName']
            }
            print('iam_instance_profile: {}'.format(iam_instance_profile))

            # Wait for Instance to become ready before adding Role
            instance_state = instance['State']['Name']
            print('instance_state: {}'.format(instance_state))
            while instance_state != 'running':
                time.sleep(5)
                instance_state = ec2.describe_instances(InstanceIds=[instance['InstanceId']])
                print('instance_state: {}'.format(instance_state))

            # attach instance profile
            response = ec2.associate_iam_instance_profile(IamInstanceProfile=iam_instance_profile, InstanceId=instance['InstanceId'])
            print('response - associate_iam_instance_profile: {}'.format(response))

            responseData = {'Success': 'Started bootstrapping for instance: '+instance['InstanceId']}
            cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData, 'CustomResourcePhysicalID')
            
        except Exception as e:
            print(e)
            responseData = {'Error': 'error'}
            cfnresponse.send(event, context, cfnresponse.FAILED, responseData, 'CustomResourcePhysicalID')
    else:
        cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData, 'CustomResourcePhysicalID')
