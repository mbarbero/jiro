local Kube = import "kube.libsonnet";
local resourcePacksTemplate = import "resource-packs.libsonnet";

local newResourceQuotas(kubernetes, controllerResources) = Kube.ResourceQuota('jenkins-instance-quota', kubernetes) {
  spec: {
    local spec = self,
    quotas_cpu::resourcePacksTemplate.pack_cpu*config.project.resourcePacks,
    quotas_mem::resourcePacksTemplate.pack_mem*config.project.resourcePacks,
    hard: {
      pods: 1 + config.jenkins.maxConcurrency,
      //"requests.storage": "%dGi" % (resourcePacksTemplate.master_hdd + config.project.resourcePacks * resourcePacksTemplate.pack_hdd),
      "requests.cpu": "%dm" % (
        Kube.stripSI(controllerResources.requests.cpu) + 
        config.jenkins.maxConcurrency * resourcePacksTemplate.jnlp_cpu +
        spec.quotas_cpu
      ),
      "requests.memory": "%dMi" % (
        Kube.stripSI(controllerResources.memory.request) + 
        config.jenkins.maxConcurrency * resourcePacksTemplate.jnlp_mem + 
        spec.quotas_mem
      ),
      "limits.cpu": "%dm" % (
        Kube.stripSI(controllerResources.limits.cpu) + 
        config.jenkins.maxConcurrency * (resourcePacksTemplate.jnlp_cpu * resourcePacksTemplate.jnlp_cpu_burst + Kube.stripSI(config.kubernetes.agents.defaultResources.cpu.limit))
      ),
      "limits.memory": self["requests.memory"],
    },
  },
};
{
  newResourceQuotas:: newResourceQuotas,
}
