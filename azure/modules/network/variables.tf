variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = list(string) }
variable "aks_subnet_prefixes" { type = list(string) }
variable "private_endpoints_subnet_prefixes" { type = list(string) }
variable "tags" { type = map(string) }
