variable "gcp_region" {
  description = "Google Cloud region used by the lab."
  type        = string
}

variable "project_name" {
  description = "Generic prefix for Google Cloud lab resources."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version or release channel target for GKE."
  type        = string
}

variable "network_cidr" {
  description = "Primary address range for the lab subnet."
  type        = string
}
