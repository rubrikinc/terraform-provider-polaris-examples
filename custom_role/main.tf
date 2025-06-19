# Example showing how to add a custom role to RSC.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

provider "polaris" {}

resource "polaris_custom_role" "compliance_auditor" {
  name        = "Compliance Auditor Role"
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
