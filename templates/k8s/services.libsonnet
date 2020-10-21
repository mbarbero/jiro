local Kube = import "kube.libsonnet";

local newService(kubernetes, serviceConfig) = Kube.Service(serviceConfig.name, kubernetes) {
  spec: {
    ports: [
      {
        name: serviceConfig.port.name,
        port: serviceConfig.port.externalPortNumber,
        protocol: "TCP",
        targetPort: serviceConfig.port.targetPortNumber,
      },
    ],
    selector: kubernetes.controllerPodLabels,
  },
};

local newJenkinsControllerService(kubernetes) = newService(kubernetes, kubernetes.services.ui);

local newJenkinsRemotingService(kubernetes) = newService(kubernetes, kubernetes.services.remoting);

{
  newJenkinsControllerService:: newJenkinsControllerService,
  newJenkinsRemotingService:: newJenkinsRemotingService,
}
