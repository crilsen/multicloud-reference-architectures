# Multi-Cloud Kubernetes Infrastructure Lab

Public Terraform portfolio project for studying Kubernetes, networking, identity, registries, observability, and governance across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure. Every implementation uses provider-native resources and generic values only.

The current end-to-end reference implementation is Google Cloud: a private-node
GKE Standard cluster with Compute Engine workers, VPC-native networking, remote
Terraform state, native observability, workload identity, and an HTTPS sample
application exposed through a Google Cloud Application Load Balancer. AWS is the
cross-cloud reference model; Azure and OCI remain intentionally incremental.

## What this project demonstrates

- separation between governance, shared foundations, workload infrastructure,
  and Kubernetes application manifests;
- reusable Terraform modules instead of a single environment-specific root;
- private worker nodes with controlled egress and no public node addresses;
- cloud-native identity, registry, logging, metrics, DNS, storage, and ingress;
- remote state with recovery controls and an explicit bootstrap procedure;
- security and cost trade-offs appropriate for a disposable engineering lab;
- documentation of the gap between a cost-conscious lab and production HA.

## Implementation status

| Area | Status | Scope |
| --- | --- | --- |
| GCP workload platform | End-to-end | VPC, private GKE Standard, Compute Engine node pool, IAM, NAT, registry, telemetry, remote state, static IP, Ingress, NEG, and managed TLS |
| AWS workload platform | Reference implementation | Organizations/SCP, networking, IAM, EKS, registry, and observability across lab and production roots |
| Azure governance | Foundation | Management groups and policy modules; workload platform remains a future increment |
| OCI governance | Foundation | Compartments and IAM policy modules; workload platform remains a future increment |
| Kubernetes sample | Runnable | Hardened Hello World deployment with probes, resource controls, health checks, and external HTTPS routing |

## Authorship

This project was conceived, architected, and developed by [@crilsen](https://github.com/crilsen).

The cloud architecture, Terraform implementations, multi-cloud governance models, automation, and documentation were created as an independent Cloud and Kubernetes engineering lab.

## Architecture model

Each provider separates governance and workload Terraform roots. `environments/organization` manages hierarchy and policy, while workload roots manage Kubernetes infrastructure. AWS currently provides distinct `environments/lab` and `environments/production` roots with enforced account boundaries.

| Boundary | AWS | Azure | GCP | OCI |
| --- | --- | --- | --- | --- |
| Management | Organizations management account | Entra tenant and governance subscription | Organization and management project | Tenancy/root compartment |
| Lab | Member account | Subscription | Project | Child compartment |
| Production | Member account | Subscription | Project | Child compartment |
| Grouping | Organizational Unit | Management Group | Folder | Parent compartment |
| Guardrail | SCP | Azure Policy | Organization Policy | No exact match; IAM policies delegate access |

OCI compartments are scopes inside one tenancy, not separate accounts. Azure subscriptions and GCP projects also differ from AWS accounts in billing, identity inheritance, and lifecycle.

## GCP reference implementation

The GCP implementation is intentionally analogous to EKS with EC2 nodes, not a
self-managed `kubeadm` cluster and not GKE Autopilot:

```text
Internet
   |
   +-- gcp-test.example.com
           |
           +-- global static IP
                   |
                   +-- external Application Load Balancer / GKE Ingress
                           |
                           +-- container-native NEG -> ClusterIP -> Pod

Administrator /32 -> public GKE API endpoint
                              |
                              +-- Google-managed control plane
                                      |
Custom-mode VPC -> private GKE Standard Compute Engine node pool
       |                 |                 |
       |                 |                 +-- Workload Identity
       |                 +-- Pod and Service secondary ranges
       +-- Cloud Router -> Cloud NAT -> controlled outbound access

Terraform -> private versioned GCS backend
Images    -> Artifact Registry
Telemetry -> Cloud Logging, Monitoring, and Managed Prometheus
```

### Key engineering decisions

| Decision | Rationale | Production evolution |
| --- | --- | --- |
| GKE Standard | Exposes node-pool, VM, upgrade, and scheduling concerns comparable to EKS + EC2 | Retain Standard where node-level control is required |
| Zonal control plane | Keeps a 90-day trial affordable | Use a regional cluster for control-plane HA |
| Private nodes | Removes direct Internet ingress to Compute Engine workers | Preserve; add tighter egress controls and private endpoints |
| Public API restricted to `/32` | Allows workstation access without a VPN for the lab | Prefer private endpoint through VPN, bastion, or corporate connectivity |
| VPC-native alias IPs | Native Pod and Service routing without hand-managed static routes | Plan CIDRs centrally for Shared VPC and multi-cluster growth |
| Dataplane V2 | Provides integrated network policy and eBPF-based data plane | Add explicit namespace policies and policy testing |
| GCS remote state | Centralizes state, locking, version recovery, and team access | Move bootstrap state and CI access into a dedicated management project |
| GKE Ingress + NEG | Demonstrates container-native load balancing and managed TLS | Add Cloud Armor, HTTPS redirect, DNS automation, and SLO monitoring |

## Layout

```text
<provider>/
├── environments/
│   ├── organization/   # hierarchy and governance
│   └── lab/            # managed Kubernetes workload
├── bootstrap/state/        # remote-state foundation where implemented
├── modules/                # provider-native components
└── README.md
kubernetes/base/            # portable Kubernetes resources
kubernetes/hello-world/     # sample app, health checks, NEG, Ingress, and TLS
docs/                       # architecture notes
scripts/                    # safety, installation, and authentication helpers
```

## GCP deployment path

1. Authenticate `gcloud` and Application Default Credentials.
2. Create the protected GCS state bucket with `gcp/bootstrap/state`.
3. Initialize or migrate `gcp/environments/lab` to the GCS backend.
4. Review and apply the VPC, GKE, IAM, registry, observability, and static IP plan.
5. Replace `gcp-test.example.com` with a domain you control and configure its DNS `A` record.
6. Apply `kubernetes/hello-world/hello-world.yaml` and wait for managed TLS.

```bash
terraform -chdir=gcp/bootstrap/state init
terraform -chdir=gcp/bootstrap/state apply \
  -var='project_id=YOUR_PROJECT_ID' \
  -var='bucket_name=YOUR_GLOBALLY_UNIQUE_TFSTATE_BUCKET'

terraform -chdir=gcp/environments/lab init -migrate-state \
  -backend-config='bucket=YOUR_GLOBALLY_UNIQUE_TFSTATE_BUCKET' \
  -backend-config='prefix=environments/lab'
terraform -chdir=gcp/environments/lab plan
```

Detailed prerequisites, commands, cost notes, and teardown order are documented
in `gcp/README.md` and `kubernetes/hello-world/README.md`.

## AWS → Azure → GCP → OCI service mapping

| Concept | AWS | Azure | GCP | OCI |
| --- | --- | --- | --- | --- |
| Network | VPC | Virtual Network | VPC network | VCN |
| Kubernetes | EKS | AKS | GKE | OKE |
| NAT | NAT Gateway | NAT Gateway | Cloud NAT | NAT Gateway |
| Registry | ECR | ACR | Artifact Registry | Container Registry |
| Identity | IAM | Entra ID and Azure RBAC | Cloud IAM | OCI IAM |
| Workload identity | Pod Identity or IRSA | Workload Identity | Workload Identity Federation | OKE workload identity |
| Secrets | Secrets Manager | Key Vault | Secret Manager | Vault |
| Monitoring | CloudWatch | Azure Monitor | Cloud Operations | Monitoring and Logging |
| DNS | Route 53 | Azure DNS | Cloud DNS | DNS |
| Private services | PrivateLink/endpoints | Private Link/endpoints | Private Service Connect | Service Gateway/private endpoints |

Mappings express intent, not feature parity.

## Safety and lifecycle

- Only known generic `terraform.tfvars` paths are allowlisted.
- CI rejects keys, certificates, state, account IDs, access keys, e-mails, embedded credentials, and nested repositories.
- Deletion protection is enabled where supported.
- Real identifiers belong only in a private working copy and must never be committed.
- Kubernetes, nodes, NAT, logs, registries, and endpoints can incur charges.
- Destroy workloads before governance; removing Terraform state does not close a cloud account.

## Verification

The Terraform roots are formatted and validated against the pinned Google
provider. The Kubernetes sample is parsed as a multi-document YAML manifest and
includes readiness/liveness probes, resource requests and limits, a non-root
container, disabled service-account token mounting, and a dedicated backend
health check.

Expected operational checks include:

```bash
terraform -chdir=gcp/environments/lab plan
kubectl get nodes
kubectl get pods,service,ingress,managedcertificate -n lab-workloads
curl https://gcp-test.example.com/healthz
```

## Lab scope and production gaps

This repository makes lab constraints explicit rather than presenting a demo as
production-ready. The GCP lab uses one zone, a small node pool, no multi-region
disaster recovery, and no availability SLO. A production implementation should
add a regional cluster, multi-zone capacity, workload PodDisruptionBudgets,
default-deny NetworkPolicies, Cloud Armor, centralized audit-log retention,
backup/restore testing, CI workload federation, policy-as-code, alerting, and a
documented upgrade and incident-response process.

Run `bash scripts/check-public-safety.sh` before publication.

## License

See [LICENSE](LICENSE).
