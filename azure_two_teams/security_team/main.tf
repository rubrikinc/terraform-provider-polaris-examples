# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

# See the README in https://github.com/rubrikinc/rubrik-polaris-sdk-for-go for
# an explanation of the service principal file.
variable "azure_credentials" {
  type        = string
  description = "Path to the Azure service principal file."
}

variable "tenant_domain" {
  type        = string
  description = "Azure tenant domain."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the Azure service principal to RSC.
resource "polaris_azure_service_principal" "default" {
  credentials   = var.azure_credentials
  tenant_domain = var.tenant_domain
}
