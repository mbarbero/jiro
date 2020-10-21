local projectPermissions(unixGroupName, projectGroupPermissionsList) = [
  {
    principal: "anonymous",
    grantedPermissions: [
      "Overall/Read",
      "Job/Read"
    ]
  },
  {
    principal: "common",
    grantedPermissions: [
      "Job/ExtendedRead"
    ]
  },
  {
    principal: "admins",
    grantedPermissions: [
      "Overall/Administer"
    ]
  },
  {
    principal: unixGroupName,
    grantedPermissions: projectGroupPermissionsList,
  },
];

local committerPermissions = [
  "Agent/Build",
  "Credentials/View",
  "Job/Build",
  "Job/Cancel",
  "Job/Configure",
  "Job/Create",
  "Job/Delete",
  "Job/Move",
  "Job/Read",
  "Job/Workspace",
  "Overall/Read",
  "Run/Delete",
  "Run/Replay",
  "Run/Update",
  "SCM/Tag",
  "View/Configure",
  "View/Create",
  "View/Delete",
  "View/Read",
];

local newJenkinsConfiguration(project, jiroMasters) = {
  version: "latest",
  maxConcurrency: 2 * project.resourcePacks,
  staticAgentCount: 0,
  agentConnectionTimeout: 180,
  timezone: "America/Toronto",
  theme: "quicksilver",
  # see https://github.com/jenkinsci/docker/pull/577
  pluginsForceUpgrade: true,
  permissions: projectPermissions(project.unixGroupName, 
    committerPermissions + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",]),
  docker: {
    registry: $.jiroMaster.docker.registry,
    repository: "eclipsecbijenkins",
    image: project.fullName,
    tag: $.jiroMaster.version,
  },
  jiroMaster: if (self.version == "latest") then jiroMasters.masters[jiroMasters.latest] else jiroMasters.masters[self.version],
};

{
  newJenkinsConfiguration:: newJenkinsConfiguration,
  projectPermissions:: projectPermissions,
  committerPermissionsList:: committerPermissions,
  defaultCommitterPermissions:: committerPermissions
}