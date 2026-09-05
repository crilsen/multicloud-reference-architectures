# Multi-Cloud Kubernetes Infrastructure Lab

Public Terraform portfolio project for studying Kubernetes, networking, identity, registries, observability, and governance across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure. Every implementation uses provider-native resources and generic values only.

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

## Layout

```text
<provider>/
├── environments/
│   ├── organization/   # hierarchy and governance
│   └── lab/            # managed Kubernetes workload
├── modules/                # provider-native components
└── README.md
kubernetes/base/           # portable Kubernetes resources
docs/                      # architecture notes
scripts/                   # public-safety checks
```

## Deployment order

1. Authenticate to a dedicated sandbox management boundary.
2. Replace `replace-with-*` placeholders privately.
3. Initialize, validate, and review `environments/organization`.
4. Apply governance only after confirming target IDs and deletion behavior.
5. Authenticate to the Lab boundary and plan `environments/lab` using separate state.

```bash
cd aws/environments/organization
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Remote state is omitted because its storage identifiers are user-owned.

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

Run `bash scripts/check-public-safety.sh` before publication.

## License

See [LICENSE](LICENSE).
