import canigen
import time
import datetime
import sys
import os
from flask import Flask
from flask import request

app = Flask(__name__, static_folder='../build', static_url_path='/')

can_sim = canigen.canigen(
    interface=os.getenv('CAN_IF'),
    database_filename='hscan.dbc')

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/api/time')
def get_current_time():
    return {'time': time.time()}

@app.route('/api/signal/<signal_name>', methods = ['GET', 'POST'])
def signal(signal_name):
    print(f"{request.method} {signal_name}", file=sys.stderr)
    if request.method == 'GET':
        return {
            'signal_name': signal_name,
            'value': can_sim.get_sig(signal_name)
            }
    if request.method == 'POST':
        data = request.get_json()
        print(f"{data}", file=sys.stderr)
        can_sim.set_sig(signal_name, data['value'])
        return {
            'signal_name': signal_name,
            'value': can_sim.get_sig(signal_name)
            }