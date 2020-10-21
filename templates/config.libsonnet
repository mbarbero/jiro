local jiroMasters = import '../../jiro-masters/masters.jsonnet';

{ 
  
  
  
  kubernetes: {
    master: {
      namespace: $.project.shortName,
      stsName: $.project.shortName
    },
  },
  maven: {
    generate: true,
    # .mavenrc: will add --batch-mode
    interactiveMode: false,
    # .mavenrc: will add -V
    showVersion: !std.startsWith($.project.fullName, "ee4j"),
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
            nexusProUrl: if std.startsWith($.project.fullName, "ee4j") then "https://jakarta.oss.sonatype.org" else "https://oss.sonatype.org",
            username: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/" + $.project.fullName + "/oss.sonatype.org/password",
            },
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/" + $.project.fullName + "/gpg/passphrase"
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
          pass: "bots/" + $.project.fullName + "/apache-maven-security-settings"
        },
      },
    },
  },
  gradle: {
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
    }
  },
  secrets: {
    "gerrit-trigger-plugin": {
      username: "genie." + $.project.shortName,
      identityFile: "/run/secrets/jenkins/ssh/id_rsa",
    }
  }
}