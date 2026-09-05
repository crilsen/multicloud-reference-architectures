variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
  sensitive   = true
}
variable "management_subscription_id" {
  description = "Subscription used to execute governance operations."
  type        = string
  sensitive   = true
}
variable "lab_subscription_id" {
  description = "Existing Lab subscription ID."
  type        = string
  sensitive   = true
}
variable "production_subscription_id" {
  description = "Existing Production subscription ID."
  type        = string
  sensitive   = true
}
variable "management_group_name" {
  description = "Stable identifier for the workloads management group."
  type        = string
}
variable "allowed_locations" {
  description = "Azure locations allowed below the workloads management group."
  type        = list(string)
}
