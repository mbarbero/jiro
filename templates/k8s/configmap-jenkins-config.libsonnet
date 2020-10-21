local Kube = import "kube.libsonnet";
{
  gen(config, jcasc):: Kube.ConfigMap("jenkins-config", config) {
    data: {
      "jenkins.yaml": std.manifestYamlDoc(jcasc)
    }
  }
}
