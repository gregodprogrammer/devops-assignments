variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "7ad60dd1-1f06-4b1f-a6b1-6a5a5a7bcc50"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = "393a8838-12b0-4787-b70f-28b6b4d0a146"
}

variable "client_id" {
  description = "SPN Client ID"
  type        = string
  default     = "05375351-4376-4b36-bd12-9c35c0325772"
}

variable "client_secret" {
  description = "SPN Client Secret - passed via pipeline"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
