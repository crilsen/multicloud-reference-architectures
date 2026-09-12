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

`environments/lab` now provisions the Azure equivalent of the GKE base:

- VNet with dedicated AKS and private-endpoint subnets;
- private AKS control plane with Azure RBAC, autoscaling, Workload Identity, OIDC and Key Vault secret rotation;
- Premium ACR with public access disabled, with the kubelet identity granted `AcrPull`;
- Azure Monitor / Log Analytics integration.

The node pool does not pin availability zones: `eastus` does not consistently support explicit zones for this subscription, and AKS rejects unsupported zone placements. `kubernetes_version` targets a GA release (for example `1.34`); AKS exposes `1.33` only under Long-Term Support. `node_vm_size` uses `Standard_D4s_v7`, as older SKUs such as `Standard_D4s_v5` are not available in every subscription and region.

Run organization and workload roots with different state. Review subscription scope, Azure Policy impact, quotas, and cost before applying.

```bash
cd environments/lab
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

For a private AKS cluster, run `az aks get-credentials` from a network that can resolve and reach the private API endpoint. Populate `admin_group_object_ids` with the Microsoft Entra group object IDs that should administer the cluster before applying.

## Test workload

`kubernetes/hello-world/hello-world-azure.yaml` publishes the same `hello-world` app on `azure-test.example.com` through an NGINX ingress controller (the Azure counterpart of the GKE ingress flow in `kubernetes/hello-world`). Install the controller once, then apply the manifest from a network that can reach the private cluster:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f kubernetes/hello-world/hello-world-azure.yaml
```

Resolve `azure-test.example.com` to the ingress controller's public IP (or add an `/etc/hosts` entry) to test without a real DNS record. `example.com` is reserved for documentation; replace the host with one you control before using it publicly.
