local Kube = import "kube.libsonnet";
local newRoute(kubernetes, deployment) = Kube.Route(kubernetes.route.name, kubernetes) {
  metadata+: {
    annotations+: {
      "haproxy.router.openshift.io/timeout": kubernetes.route.timeout,
    },
  },
  spec: {
    host: deployment.host,
    path: deployment.prefix,
    port: {
      targetPort: kubernetes.services.ui.port.name,
    },
    tls: {
      insecureEdgeTerminationPolicy: "Redirect",
      termination: "edge",
    },
    to: {
      kind: "Service",
      name: kubernetes.services.ui.name,
      weight: 100,
    },
  },
};

{
  newRoute:: newRoute,
}