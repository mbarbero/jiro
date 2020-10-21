local kubeTemplate = import "kube.libsonnet";
local roleTemplate = import "role.libsonnet";
local roleBindingTemplate = import "role-binding.libsonnet";
local routeTemplate = import "route.libsonnet";

local servicesTemplate = import "services.libsonnet";
local limitRangeTemplate = import "limit-range.libsonnet";
local resourceQuotasTemplate = import "resource-quotas.libsonnet";

local newServiceAccount(kubernetes) = kubeTemplate.ServiceAccount(kubernetes.serviceAccount.name, kubernetes);

{
  newRole:: roleTemplate.newRole,
  newRoleBinding:: roleBindingTemplate.newRoleBinding,
  newNamespace:: kubeTemplate.Namespace,
  newRoute:: routeTemplate.newRoute,
  newServiceAccount:: newServiceAccount,

  newJenkinsControllerService:: servicesTemplate.newJenkinsControllerService,
  newJenkinsRemotingService:: servicesTemplate.newJenkinsRemotingService,
  
  newLimitRange:: limitRangeTemplate.newLimitRange,
  newResourceQuotas:: resourceQuotasTemplate.newResourceQuotas,
}