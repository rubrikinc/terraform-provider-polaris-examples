terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.7.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add custom role to RSC.
resource "polaris_custom_role" "compliance_auditor" {
  name = "Compliance Auditor Role"
  description = "Compliance Auditor"

  permission {
    operation = "EXPORT_DATA_CLASS_GLOBAL"
    hierarchy {
      snappable_type = "AllSubHierarchyType"
      object_ids = [
        "GlobalResource"
      ]
    }
  }

  permission {
    operation = "VIEW_DATA_CLASS_GLOBAL"
    hierarchy {
      snappable_type = "AllSubHierarchyType"
      object_ids = [
        "GlobalResource"
      ]
    }
  }
}
