import boto3
import json

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
    
    nodes = []
    if (props['signals'] != '{}'):
      signals = json.loads(props['signals'])
      nodes = [ signal["fullyQualifiedName"] for signal in signals ]
    elif (props['network_file_definitions'] != '{}'):
      network_file_definitions = json.loads(props['network_file_definitions'])
      for definition in network_file_definitions:
        nodes = nodes + list(definition['canDbc']['signalsMap'].values())
    else:
      raise Exception("either signals or networkFileDefinitions is required")
      
    print(f"nodes for model manifest {nodes}")
    response = client.create_model_manifest(
      name = props['name'],
      description = props['description'],
      signalCatalogArn = props['signal_catalog_arn'],
      nodes = nodes
    )
    print(f"create_model_manifest response {response}")

    response = client.update_model_manifest(
      name = props['name'],
      status = 'ACTIVE'
    )
    print(f"update_model_manifest response {response}")    
    
    
    if (props['signals'] != '{}'):
      response = client.create_decoder_manifest(
        name = props['name'],
        description = props['description'],
        modelManifestArn = props['model_manifest_arn'],
        networkInterfaces = json.loads(props['network_interfaces']),
        signalDecoders = signals
      )
      print(f"create_decoder_manifest response {response}")

    if (props['network_file_definitions'] != '{}'):
      response = client.create_decoder_manifest(
        name = props['name'],
        description = props['description'],
        modelManifestArn = props['model_manifest_arn'],
        networkInterfaces = json.loads(props['network_interfaces']),
      )
      print(f"create_decoder_manifest response {response}")
      
      network_file_definitions = json.loads(props['network_file_definitions'])
      print(f"network_file_definitions {network_file_definitions}")
      response = client.import_decoder_manifest(
        name = props['name'],
        networkFileDefinitions = network_file_definitions
      )
      print(f"import_decoder_manifest response {response}")

    response = client.update_decoder_manifest(
      name = props['name'],
      status = 'ACTIVE'
    )
    print(f"update_decoder_manifest response {response}")

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

    response = client.delete_decoder_manifest(
      name = props['name']
    )
    print(f"delete_decoder_manifest response {response}")

    response = client.delete_model_manifest(
      name = props['name']
    )
    print(f"delete_model_manifest response {response}")

    return { 'PhysicalResourceId': physical_id }
