output "account" {
  description = "contains all data share account configuration"
  value       = azurerm_data_share_account.this
}

output "shares" {
  description = "contains all data shares"
  value       = azurerm_data_share.this
}

output "blob_storage_datasets" {
  description = "contains all blob storage datasets"
  value       = azurerm_data_share_dataset_blob_storage.this
}

output "data_lake_gen2_datasets" {
  description = "contains all data lake gen2 datasets"
  value       = azurerm_data_share_dataset_data_lake_gen2.this
}

output "kusto_cluster_datasets" {
  description = "contains all kusto cluster datasets"
  value       = azurerm_data_share_dataset_kusto_cluster.this
}

output "kusto_database_datasets" {
  description = "contains all kusto database datasets"
  value       = azurerm_data_share_dataset_kusto_database.this
}

output "role_assignments" {
  description = "contains all role assignments scoped to source resources"
  value       = azurerm_role_assignment.this
}
