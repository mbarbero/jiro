local Kube = import "k8s/kube.libsonnet";
local JCasC = import "jenkins/configuration.libsonnet";

local projectTemplate = import "project.libsonnet";
local jenkinsTemplate = import "jenkins.libsonnet";
local deploymentTemplate = import "deployment.libsonnet";
local kubernetesCloudTemplate = import "kubernetesCloud.libsonnet";
local kubernetesTemplate = import "kubernetes.libsonnet";

local mavenTemplate = import "maven.libsonnet";
local gradleTemplate = import "gradle.libsonnet";

local jiroMasters = import '../../jiro-masters/masters.jsonnet';
local jiroAgents = import "../../jiro-agents/agents.jsonnet";

local resourcePacksTemplate = import "k8s/resource-packs.libsonnet";

local kubeModule = import "k8s/module.libsonnet";

local newJiro(fullName, displayName) = {
  project: projectTemplate.newProject(fullName, displayName),
  jenkins: jenkinsTemplate.newJenkinsConfiguration($.project, jiroMasters),
  deployment: deploymentTemplate.newDeployment($.project),

  clouds: {
    kubernetes: kubernetesCloudTemplate.newKubernetesCloud(
      # TODO: change namespace to something agent-specific to fix #5
      $.kubernetes.namespace, 
      $.jenkins.jiroMaster.remoting.version, 
      $.maven, 
      $.gradle, 
      resourcePacksTemplate.defaultKubernetesAgentResources($.project.resourcePacks, $.jenkins.maxConcurrency), 
      jiroAgents,
    ),
  },

  kubernetes: kubernetesTemplate.newKubernetes($.project, $.deployment),

  maven: mavenTemplate.newMaven($.project.fullName),
  gradle: gradleTemplate.newGradle(),
  
  target: {
    kubernetes: {
      // Kubernetes files
  //     "configmap-jenkins-config.json": (import "k8s/configmap-jenkins-config.libsonnet").gen(tlc, $["jenkins/configuration.json"]),
      "resource-quotas.json": kubeModule.newResourceQuotas($.kubernetes, resourcePacksTemplate.kubernetesMasterResources($.project.resourcePacks, $.jenkins.maxConcurrency)),
      "limit-range.json": kubeModule.newLimitRange($.kubernetes),
      "role.json": kubeModule.newRole($.kubernetes),
      "role-binding.json": kubeModule.newRoleBinding($.kubernetes),
      "namespace.json": kubeModule.newNamespace($.kubernetes),
      "route.json": kubeModule.newRoute($.kubernetes, $.deployment),
      "service-account.json": kubeModule.newServiceAccount($.kubernetes),
      "service-jenkins-ui.json": kubeModule.newJenkinsControllerService($.kubernetes),
      "service-jenkins-discovery.json": kubeModule.newJenkinsRemotingService($.kubernetes),
      "statefulset.json": kubeModule.newStatefulSet($.kubernetes, resourcePacksTemplate.kubernetesMasterResources($.project.resourcePacks, $.jenkins.maxConcurrency)),
  //    "known-hosts.json": (import "k8s/known-hosts.libsonnet").gen(tlc),
  //     "tools-pv.json": Kube.List([
  //         (import "k8s/tools-pv.libsonnet").gen_pv(tlc),
  //         (import "k8s/tools-pv.libsonnet").gen_pvc(tlc)
  //     ]),
  //   },
  //   jenkins: {
  //     "jenkins/configuration.json": JCasC.gen(tlc),
  //     ["jenkins/theme/%s.css" % tlc.jenkins.theme]: std.extVar("jenkins.themes")[tlc.jenkins.theme] % {projectDisplayName: tlc.project.displayName},
  //     "jenkins/theme/title.css": std.extVar("jenkins.themes")["title.js"] % {projectDisplayName: tlc.project.displayName},
    },
  },
};

{
  newJiro:: newJiro
}