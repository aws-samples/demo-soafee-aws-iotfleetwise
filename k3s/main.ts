import { Construct } from 'constructs';
import { App, Chart, ChartProps } from 'cdk8s';
import * as kplus from 'cdk8s-plus-25';
const fs = require('fs');
import { VehicleSimulator } from './vsim';
//import * as cdk8s from 'cdk8s';

const CAN_IF="vcan0";
const FW_ENDPOINT="a1q6dgk6qorfqj-ats.iot.eu-central-1.amazonaws.com";
const VEHICLE_NAME="vin100";

export class MyChart extends Chart {
  constructor(scope: Construct, id: string, props: ChartProps = { }) {
    super(scope, id, props);

    const privatekey = kplus.Secret.fromSecretName(this, 'PrivateKey', 'private-key');
    const certificate = kplus.Secret.fromSecretName(this, 'Certificate', 'certificate');
    
    const pod = new kplus.Pod(this, 'Pod');

    const fwe = pod.addContainer({
      name: 'fwe',
      image: 'docker.io/library/fwe:latest',
      imagePullPolicy: kplus.ImagePullPolicy.NEVER,
      securityContext: {
        readOnlyRootFilesystem: false,
        ensureNonRoot: false,
        user: 0,
        group: 0
      }
        
    });
    fwe.env.addVariable('CAN_IF', kplus.EnvValue.fromValue(CAN_IF));
    fwe.env.addVariable('FW_ENDPOINT', kplus.EnvValue.fromValue(FW_ENDPOINT));
    fwe.env.addVariable('VEHICLE_NAME', kplus.EnvValue.fromValue(VEHICLE_NAME));
    //fwe.env.addVariable('TRACE', kplus.EnvValue.fromValue('on'));
    fwe.mount(
      '/etc/aws-iot-fleetwise/private-key.key', 
      kplus.Volume.fromSecret(this, 'PrivateKeyVolume', privatekey), 
      {
        readOnly: true,
        subPath: 'private-key.key'
      }
    );
    fwe.mount(
      '/etc/aws-iot-fleetwise/certificate.pem', 
      kplus.Volume.fromSecret(this, 'CertificateVolume', certificate), 
      {
        readOnly: true,
        subPath: 'certificate.pem'      
      }
    );


    if (fs.existsSync('/etc/virtual')) {
      new VehicleSimulator(this, 'vsim', {
        pod
      });
    }
  }
}

const app = new App();
new MyChart(app, 'demo-soafee-aws-iotfleetwise');
app.synth();
