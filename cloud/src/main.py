import os
import re
from aws_cdk import Stack, Duration, CfnOutput
from aws_cdk import aws_timestream as ts
from aws_cdk import aws_iam as iam
import cdk_aws_iotfleetwise as ifw
from constructs import Construct


class MyStack(Stack):

  def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
    super().__init__(scope, construct_id, **kwargs)

    role = iam.Role(self, "MyRole",
                    assumed_by=iam.ServicePrincipal("iotfleetwise.amazonaws.com"),
                    managed_policies=[
                        iam.ManagedPolicy.from_aws_managed_policy_name("AdministratorAccess")
                    ])

    database_name = "FleetWise"
    table_name = "FleetWise"
    database = ts.CfnDatabase(self, "MyDatabase",
                              database_name=database_name)

    table = ts.CfnTable(self, "MyTable",
                        database_name=database_name,
                        table_name=table_name)

    table.node.add_dependency(database)

    nodes = [ifw.SignalCatalogBranch('Vehicle', 'Vehicle')]
    signals_map_my_model = {}
    with open('../dbc/my_model.dbc') as f:
      lines = f.readlines()
      for line in lines:
        found = re.search(r'^\s+SG_\s+(\w+)\s+.*', line)
        if found:
          signal_name = found.group(1)
          nodes.append(ifw.SignalCatalogSensor(f'Vehicle.{signal_name}', 'DOUBLE'))
          signals_map_my_model[signal_name] = f'Vehicle.{signal_name}'
                    

    signal_catalog = ifw.SignalCatalog(self, "FwSignalCatalog",
                                        description='my signal catalog',
                                        role=role,
                                        database=database,
                                        table=table,
                                        nodes=nodes)

    with open('../dbc/my_model.dbc') as f:
      my_model = ifw.VehicleModel(self, 'MyModel1',
                                  signal_catalog=signal_catalog,
                                  name='my_model',
                                  description='My Model vehicle',
                                  network_interfaces=[ifw.CanVehicleInterface('1', 'vcan0')],
                                  network_file_definitions=[ifw.CanDefinition(
                                      '1',
                                      signals_map_my_model,
                                      [f.read()])])

    vin100 = ifw.Vehicle(self, 'vin100',
                          vehicle_name='vin100',
                          vehicle_model=my_model,
                          create_iot_thing=True)
    
    CfnOutput(self, 'private-key', value=vin100.private_key)
    CfnOutput(self, 'certificate', value=vin100.certificate_pem)
    CfnOutput(self, 'endpoint-address', value=vin100.endpoint_address)

    ifw.Campaign(self, 'MyCampaign',
                  name='my-campaign',
                  target=vin100,
                  collection_scheme=ifw.TimeBasedCollectionScheme(Duration.seconds(10)),
                  signals=[
                      ifw.CampaignSignal('Vehicle.AmbientAirTemperature'),
                      ifw.CampaignSignal('Vehicle.DoorState'),
                  ],
                  auto_approve=True)
