variable "management_group_name" { type = string }
variable "lab_subscription_id" {
  type      = string
  sensitive = true
}
variable "production_subscription_id" {
  type      = string
  sensitive = true
}
