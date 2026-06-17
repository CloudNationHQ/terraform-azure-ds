data "azurerm_client_config" "current" {}

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

    blob_properties = {
      containers = {
        sales = {
          access_type = "private"
        }
      }
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
        kind        = "CopyBased"
        description = "monthly sales export"

        datasets = {
          blob_storage = {
            sales_container = {
              container_name = module.storage.containers["sales"].name
              folder_path    = "exports"

              storage_account = {
                name                = module.storage.account.name
                resource_group_name = module.storage.account.resource_group_name
                subscription_id     = data.azurerm_client_config.current.subscription_id
              }
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
