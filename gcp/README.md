# Google Cloud: Resource Manager, Organization Policy, and GKE

Google Cloud uses an existing organization and management project. Terraform creates a protected Workloads folder and separate Lab and Production projects attached to an existing billing account.

## Hierarchy

```text
Google Cloud organization
├── Management project (execution context)
└── Kubernetes Lab Workloads folder
    ├── Lab project
    └── Production project
```

`modules/resource-hierarchy` creates folder/projects, disables default networks, links billing, and enables deletion protection. `modules/org-policy` uses Organization Policy API v2 to prevent service-account key creation and upload in descendants, encouraging short-lived identity.

```bash
cd environments/organization
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Project IDs must be globally unique. The caller needs folder/project creation, billing association, and organization-policy rights. APIs and billing must be enabled, and policy propagation is asynchronous.

## GKE workload boundary

`environments/lab` defines region, project label, Kubernetes target, and network CIDR. Module boundaries reserve VPC/Cloud NAT, GKE, Workload Identity, Artifact Registry, and Cloud Operations. Governance and workload state remain independent.
