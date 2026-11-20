variable "subscription_id" {
  description = "Azure subscription ID used for this environment."
  type        = string
}

variable "admin_source_ip_cidr" {
  description = "Administrator public IP with /32, allowed to reach the management subnet."
  type        = string
}

variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "seclab"
}

variable "environment" {
  description = "Environment name (dev, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "canadacentral"
}
