# AWS: Organizations and EKS

AWS is the comparison baseline. Governance and workloads are independent Terraform roots with separate state.

## Hierarchy

```text
Management account (existing caller)
└── Workloads OU
    ├── Lab member account
    └── Production member account
```

Terraform does not create or rename the management account. It enables Organizations features and SCPs, creates the OU and member accounts, and protects account resources from destroy. `close_on_deletion` is disabled.

The SCP catalog denies root-user API activity and prevents members from leaving the organization. SCPs cap permissions; they do not grant IAM access and do not constrain the management account.

```bash
cd environments/organization
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Use unique account e-mails privately. Import existing organizations or accounts instead of duplicating them.

## EKS architecture

The `us-east-1` workload root composes:

- `network`: VPC, two public and two private subnets, Internet Gateway, NAT Gateway, routes, endpoint security group, S3 gateway endpoint, and ECR/Logs/STS interface endpoints.
- `iam`: separate EKS control-plane and managed-node roles.
- `eks`: KMS secret encryption, control-plane logging, managed nodes, CoreDNS, kube-proxy, VPC CNI, and Pod Identity agent.
- `registry`: encrypted ECR, immutable tags, push scanning, and retention.
- `observability`: CloudWatch log retention.

```bash
cd environments/lab
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

The public API endpoint favors lab access; restrict it for broader use. One NAT Gateway reduces lab cost but is not zonally resilient. Remote state, DNS, certificates, ingress, and workload-specific autoscaling remain deliberate omissions.
