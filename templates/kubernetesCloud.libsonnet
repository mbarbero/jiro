local newAgentTemplate(jiroAgent, remotingVersion, maven, gradle, agentResources) = jiroAgent.spec + jiroAgent.variants[remotingVersion] + {
  kubernetes: {
    resources: agentResources,
    volumes: 
      maven.kubernetesCloudAgentTemplateVolumes(jiroAgent.spec.home) + 
      gradle.kubernetesCloudAgentTemplateVolumes(jiroAgent.spec.home),
  },
};

local newKubernetesCloud(namespace, remotingVersion, maven, gradle, agentResources, jiroAgents) = {
  kind: "kubernetes",
  namespace: namespace,
  podRetention: "never",
  templates: {
    [agentName]: newAgentTemplate(
      jiroAgents[agentName], 
      remotingVersion, 
      maven, 
      gradle, 
      agentResources
    ) for agentName in std.objectFields(jiroAgents) 
  },
};

{
  newKubernetesCloud:: newKubernetesCloud,
}