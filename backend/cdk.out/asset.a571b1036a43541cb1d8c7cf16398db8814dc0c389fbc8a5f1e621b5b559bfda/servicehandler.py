import boto3

def on_event(event, context):
    print(event)
    request_type = event['RequestType']
    if request_type == 'Create': 
        return on_create(event)
    if request_type == 'Update': 
        return on_update(event)
    if request_type == 'Delete': 
        return on_delete(event)
    raise Exception(f"Invalid request type: {request_type}")

def on_create(event):
    props = event["ResourceProperties"]
    print(f"create new resource with props {props}")
    client=boto3.client('iotfleetwise')
    response = client.register_account(
        iamResources={
            'roleArn': props['role_arn']
        },
        timestreamResources={
            'timestreamDatabaseName': props['database_name'],
            'timestreamTableName': props['table_name']
        }
    )
    print(response)
    return {}

def on_update(event):
    physical_id = event["PhysicalResourceId"]
    props = event["ResourceProperties"]
    print(f"update resource {physical_id} with props {props}")
    client=boto3.client('iotfleetwise')
    response = client.register_account(
        iamResources={
            'roleArn': props['role_arn']
        },
        timestreamResources={
            'timestreamDatabaseName': props['database_name'],
            'timestreamTableName': props['table_name']
        }
    )
    print(response)
    return { 'PhysicalResourceId': physical_id }

def on_delete(event):
    physical_id = event["PhysicalResourceId"]
    print('delete resource {physical_id}')
    return { 'PhysicalResourceId': physical_id }

def is_complete(event, context):
    physical_id = event["PhysicalResourceId"]
    props = event["ResourceProperties"]
    print(f"is_complete for resource {physical_id} with props {props}")
    client=boto3.client('iotfleetwise')
    response = client.get_register_account_status()
    if (response['accountStatus'] == 'REGISTRATION_PENDING' or 
        response['iamRegistrationResponse']['registrationStatus'] == 'REGISTRATION_PENDING' or
        response['timestreamRegistrationResponse']['registrationStatus'] == 'REGISTRATION_PENDING'):
        return { 'IsComplete': False }
    elif (response['accountStatus'] == 'REGISTRATION_FAILURE' or 
        response['iamRegistrationResponse']['registrationStatus'] == 'REGISTRATION_FAILURE' or
        response['timestreamRegistrationResponse']['registrationStatus'] == 'REGISTRATION_FAILURE'):
        raise Exception(f"IoT FleetWise registration has failed {response}")

    return { 'IsComplete': True }