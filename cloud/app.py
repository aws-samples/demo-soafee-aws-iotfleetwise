import os
from aws_cdk import App, Environment
from src.main import MyStack

env = Environment(
  account=os.getenv('CDK_DEFAULT_ACCOUNT'),
  region=os.getenv('CDK_DEFAULT_REGION'),
)

app = App()
MyStack(app, "demo-soafee-aws-iotfleetwise", env=env)

app.synth()