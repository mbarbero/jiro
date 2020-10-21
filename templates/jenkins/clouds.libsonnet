{
  gen(config):: [
    {
      [config.clouds[c].kind]: {
        local currentCloud = config.clouds[c],
        name: c,
        containerCapStr: config.jenkins.maxConcurrency,
        jenkinsUrl: "http://jenkins-ui.%s.svc.cluster.local%s" % [ config.kubernetes.master.namespace, config.deployment.prefix ], 
        jenkinsTunnel: "jenkins-discovery.%s.svc.cluster.local:%s" % [ config.kubernetes.master.namespace, config.deployment.jnlpPort],
          
        maxRequestsPerHostStr: 32,
        namespace: currentCloud.namespace,
        podRetention: currentCloud.podRetention,

        templates: [
          {
            local currentTemplate = currentCloud.templates[t],
            containers: [
              {
                image: "%s/%s/%s:%s" % [ currentTemplate.docker.registry, currentTemplate.docker.repository, currentTemplate.docker.image, currentTemplate.docker.tag ], 
                alwaysPullImage: true,
                livenessProbe: {
                  failureThreshold: 0,
                  initialDelaySeconds: 0,
                  periodSeconds: 0,
                  successThreshold: 0,
                  timeoutSeconds: 0,
                },
                name: "jnlp",
                resourceLimitCpu: currentTemplate.kubernetes.resources.limits.cpu,
                resourceRequestCpu: currentTemplate.kubernetes.resources.requests.cpu,
                resourceLimitMemory: currentTemplate.kubernetes.resources.limits.memory,
                resourceRequestMemory: currentTemplate.kubernetes.resources.requests.memory,
                ttyEnabled: true,
                command: "",
                args: "",
              },
            ],
            instanceCap: -1,
            name: t,
            namespace: currentCloud.namespace,
            nodeUsageMode: currentTemplate.mode,
            label: std.join(" ", currentTemplate.labels),
            envVars: [
                {
                  envVar: {
                    key: var,
                    value: std.join(" ", currentTemplate.env[var]),
                  },
                } for var in std.objectFields(currentTemplate.env)
              ],
              volumes: [
                {
                persistentVolumeClaim: {
                  claimName: "tools-claim-jiro-%s" % config.project.shortName,
                  mountPath: "/opt/tools",
                  readOnly: true
                }
              },
              {
                configMapVolume: {
                  configMapName: "known-hosts",
                  mountPath: "/home/jenkins/.ssh/"
                }
              },
              {
                emptyDirVolume: {
                  memory: false,
                  mountPath: "/home/jenkins/"
                }
              },

            ] + (
              if config.maven.generate then [
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.m2/repository"
                  }
                },
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.m2/wrapper"
                  }
                }
              ] else []
            ) + (
              if config.gradle.generate then [
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.gradle/caches"
                  }
                },
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.gradle/daemon"
                  }
                },
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.gradle/native"
                  }
                },
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.gradle/workers"
                  }
                },
                {
                  emptyDirVolume: {
                    memory: false,
                    mountPath: "/home/jenkins/.gradle/wrapper"
                  }
                }
              ] else []
            ),
            workspaceVolume: {
              emptyDirWorkspaceVolume: {
                memory: false
              }
            },
            yamlAsJson:: {
              apiVersion: "v1",
              kind: "Pod",
              spec: {
                containers: [
                  {
                    name: "jnlp",
                    volumeMounts: [
                      {
                        name: v.name,
                        mountPath: m.mountPath,
                        subPath: m.subPath,
                        readOnly: true,
                      } for v in currentTemplate.kubernetes.volumes for m in v.mounts
                    ],
                    volumes: [
                      {
                        name: v.name,
                        [if std.objectHas(v, "configMap") then "configMap"]: {
                          name: v.configMap.name,
                        },
                        [if std.objectHas(v, "secret") then "secret"]: {
                          secretName: v.secret.name,
                        }, 
                      } for v in currentTemplate.kubernetes.volumes
                    ],
                  },
                ],
              },
            },
            yaml: std.manifestYamlDoc(self.yamlAsJson)
          } for t in std.objectFields(currentCloud.templates)
        ],
      },
    } for c in std.objectFields(config.clouds)
  ],
}