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

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 4.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    is_hns_enabled      = true

    file_systems = {
      sales = {}
    }
  }
}

module "ds" {
  source = "../../"

  location            = module.rg.groups.demo.location
  resource_group_name = module.rg.groups.demo.name

  account = {
    name = module.naming.data_share_account.name_unique

    role_assignments = {
      storage_reader = {
        scope                = module.storage.account.id
        role_definition_name = "Storage Blob Data Reader"
      }
    }

    shares = {
      sales = {
        kind = "CopyBased"

        datasets = {
          data_lake_gen2 = {
            sales_fs = {
              storage_account_id = module.storage.account.id
              file_system_name   = module.storage.file_systems["sales"].name
              folder_path        = "exports"
            }
          }
        }
      }
    }
  }

  tags = {
    environment = "demo"
  }
}
