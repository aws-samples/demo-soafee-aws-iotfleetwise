import { Construct } from 'constructs';
import { App, Chart, ChartProps } from 'cdk8s';
import * as kplus from 'cdk8s-plus-25';
const fs = require('fs');
import { VehicleSimulator } from './vsim';


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
    fwe.env.addVariable('CAN_IF', kplus.EnvValue.fromValue(process.env.CAN_IF!));
    fwe.env.addVariable('FW_ENDPOINT', kplus.EnvValue.fromValue(process.env.FW_ENDPOINT!));
    fwe.env.addVariable('VEHICLE_NAME', kplus.EnvValue.fromValue(process.env.VEHICLE_NAME!));
    fwe.env.addVariable('TRACE', kplus.EnvValue.fromValue(process.env.TRACE!));
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
new MyChart(app, 'demo-soafee-aws-iotfleetwise', {
  labels:{
    app: 'demo-soafee-aws-iotfleetwise'
  }
});
app.synth();
