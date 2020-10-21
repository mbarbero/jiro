local newKubernetes(project, deployment) = {
  namespace: project.shortName,
  labels: {
    "org.eclipse.cbi.jiro/project.shortname": project.shortName,
    "org.eclipse.cbi.jiro/project.fullName": project.fullName,
  },
  controllerPodLabels: self.labels {
    "org.eclipse.cbi.jiro/jenkins.kind": "controller"
  },
  agentPodLabels: self.labels {
    "org.eclipse.cbi.jiro/jenkins.kind": "agent"
  },

  statefulSet: {
    name: project.shortName,
  },

  serviceAccount: {
    name: project.shortName,
    roleName: "jenkins-master-owner",
  },

  route: {
    name: project.shortName,
    timeout: "60s",
  },

  services: {
    ui: {
      name: "jenkins-ui",
      port: {
        externalPortNumber: 80,
        targetPortNumber: deployment.uiPort,
        name: "http"
      },
    },
    remoting: {
      name: "jenkins-discovery",
      port: {
        externalPortNumber: deployment.jnlpPort,
        targetPortNumber: deployment.jnlpPort,
        name: "jnlp"
      },
    },
  },
};

{
  newKubernetes:: newKubernetes,
}