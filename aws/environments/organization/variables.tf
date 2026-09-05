variable "aws_region" {
  description = "AWS region used for Organizations API requests."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This lab supports only us-east-1."
  }
}

variable "organization_name" {
  description = "Generic label used for organizational resources."
  type        = string
}

variable "lab_account_email" {
  description = "Unique email address for the lab member account."
  type        = string
  sensitive   = true
}

variable "production_account_email" {
  description = "Unique email address for the production member account."
  type        = string
  sensitive   = true
}

variable "account_access_role_name" {
  description = "Role created in member accounts for management-account access."
  type        = string
  default     = "OrganizationAccountAccessRole"
}
