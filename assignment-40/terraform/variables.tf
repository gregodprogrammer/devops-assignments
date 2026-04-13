variable "subscription_id" {
  description = "Azure Subscription ID - set via ARM_SUBSCRIPTION_ID env var or terraform.tfvars"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID - set via ARM_TENANT_ID env var or terraform.tfvars"
  type        = string
}

variable "client_id" {
  description = "SPN Client ID - set via ARM_CLIENT_ID env var or terraform.tfvars"
  type        = string
}

variable "client_secret" {
  description = "SPN Client Secret - set via ARM_CLIENT_SECRET env var or -var flag"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
