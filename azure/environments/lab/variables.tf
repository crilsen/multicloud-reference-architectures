variable "azure_location" {
  description = "Azure region used by the lab."
  type        = string
}

variable "project_name" {
  description = "Generic prefix for Azure lab resources."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS."
  type        = string
}

variable "vnet_cidr" {
  description = "Address range for the lab virtual network."
  type        = string
}
