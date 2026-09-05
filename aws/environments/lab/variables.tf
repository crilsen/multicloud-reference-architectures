variable "aws_region" {
  description = "AWS region used by the lab."
  type        = string
  default     = "us-east-1"
  validation {
    condition = var.aws_region == "us-east-1"
    error_message = "This lab supports only us-east-1."
  }
}

variable "project_name" {
  description = "Generic prefix applied to lab resources."
  type        = string
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project_name))
    error_message = "Use 3-31 lowercase letters, numbers, or hyphens, starting with a letter."
  }
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
}
