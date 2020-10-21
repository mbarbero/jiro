local KubeObject(apiVersion, kind, name, kubernetes) = {
  apiVersion: apiVersion,
  kind: kind,
  metadata: {
    name: name,
    labels: kubernetes.labels,
  },
};

local KubeNSObject(apiVersion, kind, name, kubernetes) = KubeObject(apiVersion, kind, name, kubernetes) {
  metadata+: {
    namespace: kubernetes.namespace,
  },
};

{
  List(items):: {
    apiVersion: "v1",
    kind: "List",
    items: [] + items,
  },

  Namespace(kubernetes):: KubeObject("v1", "Namespace", kubernetes.namespace, kubernetes),
  PersistentVolume(name, kubernetes):: KubeObject("v1", "PersistentVolume", name, kubernetes),
  
  LimitRange(name, kubernetes):: KubeNSObject("v1", "LimitRange", name, kubernetes),
  ResourceQuota(name, kubernetes):: KubeNSObject("v1", "ResourceQuota", name, kubernetes),
  RoleBinding(name, kubernetes):: KubeNSObject("v1", "RoleBinding", name, kubernetes),
  Role(name, kubernetes):: KubeNSObject("v1", "Role", name, kubernetes),
  Route(name, kubernetes):: KubeNSObject("route.openshift.io/v1", "Route", name, kubernetes),
  ServiceAccount(name, kubernetes):: KubeNSObject("v1", "ServiceAccount", name, kubernetes),
  Service(name, kubernetes):: KubeNSObject("v1", "Service", name, kubernetes),
  kubernetesMap(name, kubernetes):: KubeNSObject("v1", "kubernetesMap", name, kubernetes),
  Secret(name, kubernetes):: KubeNSObject("v1", "Secret", name, kubernetes),
  PersistentVolumeClaim(name, kubernetes):: KubeNSObject("v1", "PersistentVolumeClaim", name, kubernetes),
  StatefulSet(name, kubernetes):: KubeNSObject("apps/v1", "StatefulSet", name, kubernetes),

  stripSI(n):: (
    local suffix_len =
      if std.endsWith(n, "m") then 1
      else if std.endsWith(n, "K") then 1
      else if std.endsWith(n, "M") then 1
      else if std.endsWith(n, "G") then 1
      else if std.endsWith(n, "T") then 1
      else if std.endsWith(n, "P") then 1
      else if std.endsWith(n, "E") then 1
      else if std.endsWith(n, "Ki") then 2
      else if std.endsWith(n, "Mi") then 2
      else if std.endsWith(n, "Gi") then 2
      else if std.endsWith(n, "Ti") then 2
      else if std.endsWith(n, "Pi") then 2
      else if std.endsWith(n, "Ei") then 2
      else error "Unknown numerical suffix in " + n;
    local n_len = std.length(n);
    std.parseInt(std.substr(n, 0, n_len - suffix_len))
  ),
}