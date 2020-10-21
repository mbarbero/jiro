local Kube = import "kube.libsonnet";
local resourcePacksTemplate = import "resource-packs.libsonnet";

local newLimitRange(kubernetes) = Kube.LimitRange("jenkins-instance-limit-range", kubernetes) {
  spec: {
    local spec = self,
    limits: [
      { 
        type: "Pod",
        min: {
          cpu: "100m",
          memory: "64Mi",
        },
        max: resourcePacksTemplate.podMaxLimits,
      },
      {
        type: "Container",
        min: {
          cpu: "100m",
          memory: "64Mi",
        },
        default: resourcePacksTemplate.containerDefaultLimits,
        defaultRequest: resourcePacksTemplate.containerDefaultRequests,
        max: resourcePacksTemplate.containerMaxLimits,
      },
    ],
  },
};

{
  newLimitRange:: newLimitRange,
}
