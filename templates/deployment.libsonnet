local newDeployment(project) = {
  host: "ci.eclipse.org",
  prefix: "/" + project.shortName,
  url: "https://%s%s" % [ self.host, self.prefix, ],
  uiPort: 8080,
  jnlpPort: 50000,
  controlPort: 8081,
};
{
  newDeployment:: newDeployment,
}