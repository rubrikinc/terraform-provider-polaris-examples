terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.5.0"
    }
  }
}

variable "outpost_profile" {
  type        = string
  description = "Outpost account AWS profile."
}

variable "account_profile" {
  type        = string
  description = "Account AWS profile."
}

resource "polaris_aws_account" "outpost" {
  profile = var.outpost_profile

  outpost {
    permission_groups = [
      "BASIC",
    ]
  }
}

resource "polaris_aws_account" "account" {
  profile = var.account_profile

  cyber_recovery_data_scanning {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }

  data_scanning {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }

  dspm {
    permission_groups = [
      "BASIC",
    ]

    regions = [
      "us-east-2",
    ]
  }

  depends_on = [
    polaris_aws_account.outpost,
  ]
}
