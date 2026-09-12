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

variable "aks_subnet_prefixes" {
  description = "CIDRs used by AKS nodes and pods."
  type        = list(string)
}

variable "private_endpoints_subnet_prefixes" {
  description = "CIDRs reserved for private endpoints."
  type        = list(string)
}

variable "node_vm_size" { type = string }
variable "node_min_count" { type = number }
variable "node_max_count" { type = number }
variable "node_os_disk_size_gb" { type = number }
variable "admin_group_object_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
