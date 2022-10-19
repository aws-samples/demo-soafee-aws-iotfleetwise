#!/usr/bin/python3
# Copyright 2020 Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: LicenseRef-.amazon.com.-AmznSL-1.0
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
# http://aws.amazon.com/asl/
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

import canigen
import time
import datetime
import argparse

parser = argparse.ArgumentParser(description='Generates SocketCAN messages for AWS IoT FleetWise demo')
parser.add_argument('-i', '--interface', default='vcan0', help='CAN interface, e.g. vcan0')
parser.add_argument('-o', '--only-obd', action='store_true', help='Only generate OBD messages')
args = parser.parse_args()

can_sim = canigen.canigen(
    interface=args.interface,
    database_filename=None if args.only_obd else 'hscan.dbc')

def set_with_print(func, name, val):
    print(str(datetime.datetime.now())+" Set "+name+" to "+str(val))
    func(name, val)

try:
    while True:
        for i in range(1, 7):
            set_with_print(can_sim.set_sig, 'Gear', i)
            set_with_print(can_sim.set_sig, 'VehicleSpeed', i*10)
            time.sleep(2)
except KeyboardInterrupt:
    print("Stopping...")
    can_sim.stop()
except:
    raise

