#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
{
  gen(config):: {
    jenkins: {
      numExecutors: 0,
      scmCheckoutRetryCount: 2,
      mode: "EXCLUSIVE",
      systemMessage: "",

      disableRememberMe: false,
      agentProtocols: [
        "JNLP4-connect",
        "Ping",
      ],

      authorizationStrategy: {
        projectMatrix: {
          permissions: std.setDiff(
            std.set([ 
            "%s:%s" % [g, p.principal]
              for p in config.jenkins.permissions for g in if std.objectHas(p, "grantedPermissions") then p.grantedPermissions else [] ]),
            std.set([ 
            "%s:%s" % [g, p.principal]
              for p in config.jenkins.permissions for g in if std.objectHas(p, "withheldPermissions") then p.withheldPermissions else [] ])
          ),
        },
      },

      markupFormatter: "rawHtml",
      crumbIssuer: {
        standard: {
          excludeClientIPFromCrumb: false
        },
      },
      remotingSecurity: {
        enabled: true
      },

      securityRealm: {
        ldap: {
          configurations: [
            {
              displayNameAttributeName: "cn",
              groupSearchBase: "ou=group",
              rootDN: "dc=eclipse,dc=org",
              server: "ldaps://ldapcluster.eclipse.org",
              userSearch: "mail={0}",
              mailAddressAttributeName: "mail",
            },
          ],
        },
      },

      clouds: (import "clouds.libsonnet").gen(config),
    },

    security: {
      apiToken: {
        creationOfLegacyTokenEnabled: false,
        tokenGenerationOnCreationEnabled: false,
        usageStatisticsEnabled: true
      },
      queueItemAuthenticator: {
        authenticators: [
          {
            global: {
              strategy: "triggeringUsersAuthorizationStrategy"
            },
          },
        ],
      },
      sSHD: {
        port: -1
      },
    },

    unclassified: {
      location: {
        adminAddress: "ci-admin@eclipse.org",
        url: "https://ci.eclipse.org%s" % config.deployment.prefix
      },
      mailer: {
        replyToAddress: "ci-admin@eclipse.org",
        smtpHost: "mail.eclipse.org"
      },
      "email-ext": {
        defaultContentType: "text/html"
      },
      globalDefaultFlowDurabilityLevel: {
        durabilityHint: "PERFORMANCE_OPTIMIZED"
      },

      "simple-theme-plugin": {
        elements: [
          {
            cssUrl: {
              url: "%s/userContent/theme/%s.css" % [ config.deployment.prefix, config.jenkins.theme ]
            },
          },
          {
            cssUrl: {
              url: "//fonts.googleapis.com/css?family=Libre+Franklin:400,700,300,600,100"
            },
          },
          {
            jsUrl: {
              url: "%s/userContent/theme/title.js" % config.deployment.prefix
            },
          },
        ],
      },
      buildDiscarders: {
        configuredBuildDiscarders: [
          "jobBuildDiscarder",
          {
            simpleBuildDiscarder: {
              discarder: {
                logRotator: {
                  artifactNumToKeepStr: "5",
                  numToKeepStr: "128"
                },
              },
            },
          },
        ],
      },
    },

    sonarGlobalConfiguration: {
      buildWrapperEnabled: true,
      installations: [
        {
          name: "SonarCloud.io",
          serverUrl: "https://sonarcloud.io",
          triggers: {
            skipScmCause: false,
            skipUpstreamCause: false,
          },
        },
      ],
    },

    gitLabConnectionConfig: {
      connections: [
        {
          clientBuilderId: "autodetect",
          connectionTimeout: 10,
          ignoreCertificateErrors: false,
          name: "gitlab.eclipse.org",
          readTimeout: 10,
          url: "https://gitlab.eclipse.org",
        },
      ],
    },
    gitLabServers: {
      servers: [
        {
          name: "gitlab.eclipse.org",
          serverUrl: "https://gitlab.eclipse.org",
        },
      ],
    },
  
    tool: {
      jdk: {
        installations: import "tools/jdk.libsonnet",
      },
      ant: {
        installations: import "tools/ant.libsonnet",
      },
      maven: {
        installations: import "tools/maven.libsonnet",
      },
      git: {
        installations: [
          {
            name: "Default",
            home: "git"
          }
        ],
      },
    },
  },
}