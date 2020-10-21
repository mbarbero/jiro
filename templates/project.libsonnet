local newProject(fullName, displayName) = {
  shortName: std.split(self.fullName, ".")[std.length(std.split(self.fullName, "."))-1],
  fullName: fullName,
  displayName: displayName,
  unixGroupName: self.fullName,
  resourcePacks: 1,
};
{
  newProject:: newProject,
}