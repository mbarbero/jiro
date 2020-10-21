local kube = import "kube.libsonnet";

// Resource pack definition
local pack_cpu=2000;
local pack_mem=8*1024;
local pack_hdd=100;

// Resource constants for Jenkins master
local master_base_cpu_req=500;
local master_max_cpu_req=4000;
local master_min_cpu_limit=2000;
local master_max_cpu_limit=8000;
local master_cpu_burst=2;
local master_hdd=100;

local master_base_mem=1024;
local master_max_mem=8*1024;

local master_cpu_per_agent=150;
local master_mem_per_agent=256;
local master_min_agent_for_additional_resources=2;

// Resource constants for Jenkins dynamic agents
local agent_max_cpu_per_pod_or_container=8000;
local agent_max_mem_per_pod_or_container=16*1024;
local agent_min_cpu_limit=2000;
local jnlp_cpu_burst=1.5;
local jnlp_cpu=200;
local jnlp_mem=256;

local defaultKubernetesAgentResources(resourcePacks, maxConcurrency) = {
  requests: {
    cpu: "%dm" % std.min(
      agent_max_cpu_per_pod_or_container, 
      pack_cpu * resourcePacks / maxConcurrency
    ) + jnlp_cpu,
    memory: $.limits.memory,
  },
  limits: {
    cpu: "%dm" % std.min(
      agent_max_cpu_per_pod_or_container, 
      std.max(
        pack_cpu * resourcePacks / maxConcurrency, 
        agent_min_cpu_limit
      )
    ) + (jnlp_cpu * jnlp_cpu_burst),
    memory: "%dMi" % std.min(
      agent_max_mem_per_pod_or_container, 
      pack_mem * resourcePacks / maxConcurrency
    ) + jnlp_mem,
  },
};

local kubernetesMasterResources(maxConcurrency, agentCount) = {
  requests: {
    cpu: "%dm" % std.min(
      master_max_cpu_req, 
      master_base_cpu_req + std.max(
        0, 
        maxConcurrency - master_min_agent_for_additional_resources + agentCount
      ) * master_cpu_per_agent
    ),
    memory: $.limits.memory,
  },
  limits: {
    cpu: "%dm" % std.max(
      master_min_cpu_limit, 
      master_cpu_burst * kube.stripSI($.requests.cpu)
    ),
    memory: "%dMi" % std.min(
      master_max_mem, 
      master_base_mem + master_mem_per_agent * (maxConcurrency + agentCount)
    ),
  },
};

local containerDefaultLimits = {
  cpu: "%dm" % (jnlp_cpu * jnlp_cpu_burst),
  memory: "%dMi" % jnlp_mem,
};

local containerDefaultRequests = {
  cpu: "%dm" % jnlp_cpu,
  memory: "%dMi" % jnlp_mem,
};

local podMaxLimits = {
  cpu: "%dm" % std.max(
    master_max_cpu_limit, 
    agent_max_cpu_per_pod_or_container
  ) + (jnlp_cpu * jnlp_cpu_burst),
  memory: "%dMi" % std.max(
    master_max_mem,
    agent_max_mem_per_pod_or_container,
  ) + jnlp_mem,
};

local containerMaxLimits = {
  cpu: "%dm" % std.max(
    master_max_cpu_limit, 
    agent_max_cpu_per_pod_or_container
  ),
  memory: "%dMi" % std.max(
    master_max_mem,
    agent_max_mem_per_pod_or_container,
  ),
};

{
  defaultKubernetesAgentResources:: defaultKubernetesAgentResources,
  kubernetesMasterResources:: kubernetesMasterResources,

  podMaxLimits:: podMaxLimits,
  containerDefaultLimits:: containerDefaultLimits,
  containerDefaultRequests:: containerDefaultRequests,
  containerMaxLimits:: containerMaxLimits,
}