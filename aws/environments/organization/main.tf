provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.organization_name
      ManagedBy = "Terraform"
      Purpose   = "Learning"
    }
  }
}

data "aws_caller_identity" "management" {}

module "organization" {
  source = "../../modules/organizations"

  organization_name         = var.organization_name
  lab_account_email         = var.lab_account_email
  production_account_email  = var.production_account_email
  account_access_role_name  = var.account_access_role_name
}

module "service_control_policies" {
  source = "../../modules/scp"

  target_id = module.organization.workloads_organizational_unit_id
}
