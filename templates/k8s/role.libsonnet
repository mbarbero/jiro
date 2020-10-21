local Kube = import "kube.libsonnet";

local newRole(kubernetes) = Kube.Role(kubernetes.serviceAccount.roleName, kubernetes) {
  rules: [
    {
      apiGroups: [""],
      resources: ["pods", "pods/exec"],
      verbs: ["create","delete","get","list","patch","update","watch"],
    },
    {
      apiGroups: [""],
      resources: ["pods/log", "events"],
      verbs: ["get","list","watch"],
    },
  ],
};

{
  newRole:: newRole,
}
