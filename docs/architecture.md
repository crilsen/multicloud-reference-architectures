# Architecture

Each cloud implementation independently expresses the same goals: private workers, a managed Kubernetes control plane, least-privilege workload identity, encryption, and provider-native observability.

AWS is reference vocabulary, not a resource-by-resource translation template. Azure, GCP, and OCI implementations must use their native patterns and document semantic differences.

## AWS decisions

- One region limits complexity and cost.
- Two availability zones demonstrate zonal resilience.
- Nodes use private subnets; public subnets provide controlled egress and can host public load balancers.
- VPC endpoints provide private access to core AWS APIs.
- Kubernetes secrets use a customer-managed KMS key.
- Logs use short retention suitable for a lab.

The public EKS API endpoint is enabled for accessibility. Restrict its CIDRs or disable it outside an isolated lab.

## AWS account boundaries

The AWS organization separates governance from workloads. The existing management account owns Organizations and SCP administration. Lab and production are member accounts inside a workloads OU and receive the same preventive baseline. Workload infrastructure should not be deployed into the management account.
