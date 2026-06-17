# data share account
resource "azurerm_data_share_account" "this" {
  name                = var.account.name
  location            = coalesce(var.account.location, var.location)
  resource_group_name = coalesce(var.account.resource_group_name, var.resource_group_name)
  tags                = coalesce(var.account.tags, var.tags)

  identity {
    type = "SystemAssigned"
  }
}

# role assignments
resource "azurerm_role_assignment" "this" {
  for_each = var.account.role_assignments

  scope                            = each.value.scope
  role_definition_name             = each.value.role_definition_name
  role_definition_id               = each.value.role_definition_id
  principal_id                     = coalesce(each.value.principal_id, azurerm_data_share_account.this.identity[0].principal_id)
  principal_type                   = each.value.principal_type
  condition                        = each.value.condition
  condition_version                = each.value.condition_version
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
  description                      = each.value.description
}

# shares
resource "azurerm_data_share" "this" {
  for_each = var.account.shares

  name        = coalesce(each.value.name, each.key)
  account_id  = azurerm_data_share_account.this.id
  kind        = each.value.kind
  description = each.value.description
  terms       = each.value.terms

  dynamic "snapshot_schedule" {
    for_each = each.value.snapshot_schedule != null ? { "this" = each.value.snapshot_schedule } : {}

    content {
      name       = coalesce(snapshot_schedule.value.name, "${each.key}-schedule")
      recurrence = snapshot_schedule.value.recurrence
      start_time = snapshot_schedule.value.start_time
    }
  }
}

# blob storage datasets
resource "azurerm_data_share_dataset_blob_storage" "this" {
  for_each = merge([
    for sk, s in var.account.shares : {
      for dk, d in s.datasets.blob_storage :
      "${sk}.${dk}" => merge(d, { share_key = sk })
    }
  ]...)

  name           = coalesce(each.value.name, element(split(".", each.key), 1))
  data_share_id  = azurerm_data_share.this[each.value.share_key].id
  container_name = each.value.container_name
  file_path      = each.value.file_path
  folder_path    = each.value.folder_path

  storage_account {
    name                = each.value.storage_account.name
    resource_group_name = each.value.storage_account.resource_group_name
    subscription_id     = each.value.storage_account.subscription_id
  }

  depends_on = [
    azurerm_role_assignment.this
  ]
}

# data lake gen2 datasets
resource "azurerm_data_share_dataset_data_lake_gen2" "this" {
  for_each = merge([
    for sk, s in var.account.shares : {
      for dk, d in s.datasets.data_lake_gen2 :
      "${sk}.${dk}" => merge(d, { share_key = sk })
    }
  ]...)

  name               = coalesce(each.value.name, element(split(".", each.key), 1))
  share_id           = azurerm_data_share.this[each.value.share_key].id
  storage_account_id = each.value.storage_account_id
  file_system_name   = each.value.file_system_name
  file_path          = each.value.file_path
  folder_path        = each.value.folder_path

  depends_on = [
    azurerm_role_assignment.this
  ]
}

# kusto cluster datasets
resource "azurerm_data_share_dataset_kusto_cluster" "this" {
  for_each = merge([
    for sk, s in var.account.shares : {
      for dk, d in s.datasets.kusto_cluster :
      "${sk}.${dk}" => merge(d, { share_key = sk })
    }
  ]...)

  name             = coalesce(each.value.name, element(split(".", each.key), 1))
  share_id         = azurerm_data_share.this[each.value.share_key].id
  kusto_cluster_id = each.value.kusto_cluster_id

  depends_on = [
    azurerm_role_assignment.this
  ]
}

# kusto database datasets
resource "azurerm_data_share_dataset_kusto_database" "this" {
  for_each = merge([
    for sk, s in var.account.shares : {
      for dk, d in s.datasets.kusto_database :
      "${sk}.${dk}" => merge(d, { share_key = sk })
    }
  ]...)

  name              = coalesce(each.value.name, element(split(".", each.key), 1))
  share_id          = azurerm_data_share.this[each.value.share_key].id
  kusto_database_id = each.value.kusto_database_id

  depends_on = [
    azurerm_role_assignment.this
  ]
}
