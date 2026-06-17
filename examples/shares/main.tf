module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "ds" {
  source  = "cloudnationhq/ds/azure"
  version = "~> 1.0"

  location            = module.rg.groups.demo.location
  resource_group_name = module.rg.groups.demo.name

  account = {
    name = module.naming.data_share_account.name_unique

    shares = {
      sales = {
        kind        = "CopyBased"
        description = "monthly sales snapshot"
        terms       = "for analytics use only"

        snapshot_schedule = {
          recurrence = "Day"
          start_time = "2026-01-01T00:00:00Z"
        }
      }

      inventory = {
        kind        = "InPlace"
        description = "in-place inventory share"
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
