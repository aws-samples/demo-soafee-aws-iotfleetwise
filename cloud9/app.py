#!/usr/bin/env python3
import os

import aws_cdk as cdk

from src.mainstack import MainStack


app = cdk.App()
MainStack(app, "cloud9-env",
    synthesizer=cdk.BootstraplessSynthesizer()
)

app.synth()
