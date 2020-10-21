local newGradle() = {
  generate: false,

  files: {
    "gradle.properties": {
      eclipseRepoUsername: {
        pass: "nexus/username",
      },
      eclipseRepoPassword: {
        pass: "nexus/password",
      },
    }
  },
  
  local kubernetesCloudAgentTemplateVolumes(agentHome) = if $.generate then [
    {
      name: "gradle-secret-dir",
      secret: { name: "gradle-secret-dir", },
      mounts: [
        {
          mountPath: agentHome + "/.gradle/" + self.subPath,
          subPath: propertiesFile,
        } for propertiesFile in std.objectFields($.files)
      ],
    },
  ] else [
  ],

  kubernetesCloudAgentTemplateVolumes:: kubernetesCloudAgentTemplateVolumes,
};

{
  newGradle:: newGradle,
}