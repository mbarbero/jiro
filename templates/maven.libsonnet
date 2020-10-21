local newMaven(projectFullName) = {
    generate: true,
    # .mavenrc: will add --batch-mode
    interactiveMode: false,
    # .mavenrc: will add -V
    showVersion: !std.startsWith(projectFullName, "ee4j"),
    # .mavenrc: will set -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener to given level
    transferListenerLogLevel: "warn",
    # will append everything from there to .mavenrc file
    mavenrc: "",

    files: {
      "settings.xml": {
        color: "always",
        servers: {
          "repo.eclipse.org": {
            username: {
              pass: "nexus/username",
            },
            password: {
              pass: "nexus/password",
            },
          },
          ossrh: {
            nexusProUrl: if std.startsWith(projectFullName, "ee4j") then "https://jakarta.oss.sonatype.org" else "https://oss.sonatype.org",
            username: {
              pass: "bots/" + projectFullName + "/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/" + projectFullName + "/oss.sonatype.org/password",
            },
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/" + projectFullName + "/gpg/passphrase"
            },
          },
        },
        mirrors: {
          "eclipse.maven.central.mirror": {
            name: "Eclipse Central Proxy",
            url: "https://repo.eclipse.org/content/repositories/maven_central/",
            mirrorOf: "central",
          },
        },
      },
      "settings-security.xml": {
        master: {
          pass: "bots/" + projectFullName + "/apache-maven-security-settings"
        },
      },
    },

    local kubernetesCloudAgentTemplateVolumes(agentHome) = if $.generate then [
      {
        name: "m2-secret-dir",
        secret: { name: "m2-secret-dir", },
        mounts: [
          {
            mountPath: agentHome + "/.m2/" + self.subPath,
            subPath: settingsFile,
          } for settingsFile in std.objectFields($.files)
        ],
      },
      {
        name: "m2-dir",
        configMap: { name: "m2-dir", },
        mounts: [
          {
            mountPath: agentHome + "/.m2/" + self.subPath,
            subPath: "toolchains.xml"
          },
          {
            mountPath: agentHome + "/" + self.subPath,
            subPath: ".mavenrc"
          },
        ],
      },
    ] else [
    ],

    kubernetesCloudAgentTemplateVolumes:: kubernetesCloudAgentTemplateVolumes,
};

{
  newMaven:: newMaven,
}