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
  source = "../../"

  location            = module.rg.groups.demo.location
  resource_group_name = module.rg.groups.demo.name

  account = {
    name = module.naming.data_share_account.name_unique
  }

  tags = {
    environment = "demo"
  }
}
