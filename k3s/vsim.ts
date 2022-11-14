import { Construct } from 'constructs';
import * as kplus from 'cdk8s-plus-25';


export interface VehicleSimulatorProps {
  pod: kplus.Pod
}

export class VehicleSimulator extends Construct {
  constructor(scope: Construct, id: string, props: VehicleSimulatorProps) {
    super(scope, id);

    props.pod.addContainer({
      name: 'signalmesh',
      image: 'docker.io/library/alpine:3',
      command: ["/bin/sh","-c"],
      args: ["ip link add dev vcan0 type vcan && ip link set vcan0 up; tail -f /dev/null"],
      securityContext: {
        privileged: true,
        allowPrivilegeEscalation: true,
        ensureNonRoot: false,
        user: 0,
        group: 0
      }
    })

    const vsim = props.pod.addContainer({
      name: 'vsim',
      image: 'docker.io/library/vsim:latest',
      imagePullPolicy: kplus.ImagePullPolicy.NEVER,
      securityContext: {
        readOnlyRootFilesystem: false,
        ensureNonRoot: false,
        user: 0,
        group: 0
      }
    });
    vsim.addPort({ number: 3000 });
    vsim.env.addVariable('CAN_IF', kplus.EnvValue.fromValue('vcan0'));

    const ui = new kplus.Service(this, 'UI', {
      type: kplus.ServiceType.NODE_PORT
    });
    ui.select(props.pod);
    ui.bind(3000);

    const ingress = new kplus.Ingress(this, 'Ingress');
    ingress.metadata.addAnnotation('traefik.ingress.kubernetes.io/router.entrypoints', 'web');

    ingress.addRule('/', kplus.IngressBackend.fromService(ui))
  }
}