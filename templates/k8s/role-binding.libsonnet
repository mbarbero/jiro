local Kube = import "kube.libsonnet";

local newRoleBinding(kubernetes) = Kube.RoleBinding(kubernetes.serviceAccount.roleName, kubernetes) {
  roleRef: {
    kind: "Role",
    name: kubernetes.serviceAccount.roleName,
    namespace: kubernetes.namespace,
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: kubernetes.serviceAccount.name,
      namespace: kubernetes.namespace,
    },
  ],
};
{
  newRoleBinding:: newRoleBinding
}