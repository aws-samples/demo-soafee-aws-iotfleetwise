from projen.awscdk import AwsCdkPythonApp

project = AwsCdkPythonApp(
    author_email="salamida@amazon.com",
    author_name="Francesco Salamida",
    cdk_version="2.13.0",
    module_name="src",
    name="demo-soafee-aws-iotfleetwise",
    version="0.1.0",
    deps=[
        'cdk-aws-iotfleetwise>=0.3.2',
    ]
)

project.synth()
