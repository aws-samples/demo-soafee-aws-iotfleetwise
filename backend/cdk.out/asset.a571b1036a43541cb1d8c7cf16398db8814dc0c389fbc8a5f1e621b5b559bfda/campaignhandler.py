import boto3
import json
import time

def on_event(event, context):
    print(f'on_event {event} {context}')
    request_type = event['RequestType']
    if request_type == 'Create': 
        return on_create(event)
    if request_type == 'Update': 
        return on_update(event)
    if request_type == 'Delete': 
        return on_delete(event)
    raise Exception("Invalid request type: {request_type}")

def on_create(event):
    props = event["ResourceProperties"]
    print(f"create new resource with props {props}")
    client=boto3.client('iotfleetwise')
    
    response = client.create_campaign(
      name = props['name'],
      signalCatalogArn = props['signal_catalog_arn'],
      targetArn = props['target_arn'],
      collectionScheme = json.loads(props['collection_scheme']),
      signalsToCollect = json.loads(props['signals_to_collect'])
    )
    print(f"create_campaign response {response}")
    
    if props['auto_approve'] == 'true':
        retry_count = 10;
        delay = 2;
        while retry_count > 1:
            print(f"waiting for campaign {props['name']} to be created")
            response = client.get_campaign(name = props['name'])
            print(f"get_campaign response {response}")
            if response['status'] == "WAITING_FOR_APPROVAL":
                break
            time.sleep(delay)
            retry_count = retry_count - 1            
        print(f"approving the campaign {props['name']}")
        response = client.update_campaign(
          name = props['name'],
          action = 'APPROVE'
        )
        print(f"update_campaign response {response}")
    return { 'PhysicalResourceId': props['name'] }

def on_update(event):
    physical_id = event["PhysicalResourceId"]
    props = event["ResourceProperties"]
    print(f"update resource {physical_id} with props {props}")
    raise Exception("update not implemented yet")
    #return { 'PhysicalResourceId': physical_id }

def on_delete(event):
    physical_id = event["PhysicalResourceId"]
    props = event["ResourceProperties"]
    print(f"delete resource {props['name']} {physical_id}")
    client=boto3.client('iotfleetwise')

    response = client.delete_campaign(
      name = props['name'],
    )
    print(f"delete_campaign response {response}")

    return { 'PhysicalResourceId': physical_id }
