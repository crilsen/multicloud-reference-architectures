# Azure: Management Groups, Policy, and AKS

Azure uses an existing Microsoft Entra tenant and governance subscription. Terraform associates existing Lab and Production subscriptions; subscription purchase and billing enrollment remain external.

## Hierarchy

```text
Microsoft Entra tenant
├── Governance subscription (execution context)
└── Kubernetes Lab Workloads management group
    ├── Lab subscription
    └── Production subscription
```

`modules/management-groups` creates the Management Group and associations. `modules/policy` defines and assigns an allowed-locations policy inherited by both subscriptions. Azure Policy is conceptually comparable to an SCP for deny controls, but has different evaluation and effects; it never grants RBAC access.

```bash
cd environments/organization
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Replace tenant/subscription placeholders privately. The caller needs tenant-level Management Group and policy permissions. Moving subscriptions changes inherited governance, and policy propagation is asynchronous.

## AKS workload boundary

`environments/lab` defines the location, project label, Kubernetes target, and VNet CIDR. The module boundaries reserve provider-native network, AKS, Workload Identity, ACR, and Azure Monitor components without coupling them to governance state.

Run organization and workload roots with different state. Review subscription scope, Azure Policy impact, quotas, and cost before applying.
