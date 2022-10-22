import boto3
#import os
import json

def on_event(event, context):
    print(f'on_event {event} {context}')
    request_type = event['RequestType']
    if request_type == 'Create': 
        return on_create(event, context)
    if request_type == 'Update': 
        return on_update(event)
    if request_type == 'Delete': 
        return on_delete(event)
    raise Exception("Invalid request type: {request_type}")

def on_create(event, context):
    props = event["ResourceProperties"]
    print(f"create new resource with props {props}")    
    ret = { 'PhysicalResourceId': props['vehicle_name'] }
    
    if (props['create_iot_thing']):
        print("creating certificate for iot thing")
        client=boto3.client('iot')
        response = client.create_keys_and_certificate(
            setAsActive=True
        )
        print(f"create_keys_and_certificate response {response}")
        ret['Data'] = {
            'certificateId': response['certificateId'],
            'certificateArn': response['certificateArn'],
            'certificatePem': response['certificatePem'],
            'privateKey': response['keyPair']['PrivateKey']           
        }
        print(f"describe_endpoint response {response}")
        response = client.describe_endpoint(
            endpointType='iot:Data-ATS'
        )
        print(f"describe_endpoint response {response}")
        ret['Data']['endpointAddress'] = response['endpointAddress']
        
    client=boto3.client('iotfleetwise')
    response = client.create_vehicle(
      associationBehavior = "CreateIotThing" if props['create_iot_thing'] else "ValidateIotThingExists",
      vehicleName = props['vehicle_name'],
      modelManifestArn = props['model_manifest_arn'],
      decoderManifestArn = props['decoder_manifest_arn'],
    )
    print(f"create_vehicle response {response}")
    return ret;

def on_update(event):
    physical_id = event["PhysicalResourceId"]
    props = event["ResourceProperties"]
    print(f"update resource {physical_id} with props {props}")
    raise Exception("update not implemented yet")
    #return { 'PhysicalResourceId': physical_id }

def on_delete(event):
    physical_id = event["PhysicalResourceId"]
    props = event["ResourceProperties"]
    print(f"delete resource {props['vehicle_name']} {physical_id}")
    client=boto3.client('iotfleetwise')

    response = client.delete_vehicle(
      vehicleName = props['vehicle_name']
    )
    print(f"delete_vehicle response {response}")
    
    if (props['create_iot_thing']):
        client=boto3.client('iot')
        
        response = client.list_thing_principals(
            thingName=props['vehicle_name']
        )
        print(f"list_thing_principals response {response}")
        
        for cert in response['principals']:
            print(f"delete_certificate {cert}")
            response = client.delete_certificate(
                certificateId=cert,
                forceDelete=True
            )
            print(f"delete_certificate response {response}")

        print(f"delete_thing")
        response = client.delete_thing(
            thingName=props['vehicle_name']
        )
        print(f"delete_thing response {response}")
    return { 'PhysicalResourceId': physical_id }
