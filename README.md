# Data Share

This terraform module simplifies the creation and management of azure data share resources on Azure, supporting copy-based and in-place shares with blob storage, data lake gen2, and kusto cluster and database datasets, all managed through code.

## Features

Capability to create a data share account with a system assigned managed identity.

Supports multiple shares per account with optional snapshot schedules.

Supports blob storage, data lake gen2, kusto cluster and kusto database datasets.

Utilization of terratest for robust validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_data_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_share) (resource)
- [azurerm_data_share_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_share_account) (resource)
- [azurerm_data_share_dataset_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_share_dataset_blob_storage) (resource)
- [azurerm_data_share_dataset_data_lake_gen2.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_share_dataset_data_lake_gen2) (resource)
- [azurerm_data_share_dataset_kusto_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_share_dataset_kusto_cluster) (resource)
- [azurerm_data_share_dataset_kusto_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_share_dataset_kusto_database) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_account"></a> [account](#input\_account)

Description: describes data share account related configuration

Type:

```hcl
object({
    name                = string
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
    role_assignments = optional(map(object({
      scope                            = string
      role_definition_name             = optional(string)
      role_definition_id               = optional(string)
      principal_id                     = optional(string)
      principal_type                   = optional(string)
      condition                        = optional(string)
      condition_version                = optional(string)
      skip_service_principal_aad_check = optional(bool)
      description                      = optional(string)
    })), {})
    shares = optional(map(object({
      name        = optional(string)
      kind        = string
      description = optional(string)
      terms       = optional(string)
      snapshot_schedule = optional(object({
        name       = optional(string)
        recurrence = string
        start_time = string
      }))
      datasets = optional(object({
        blob_storage = optional(map(object({
          name           = optional(string)
          container_name = string
          file_path      = optional(string)
          folder_path    = optional(string)
          storage_account = object({
            name                = string
            resource_group_name = string
            subscription_id     = string
          })
        })), {})
        data_lake_gen2 = optional(map(object({
          name               = optional(string)
          storage_account_id = string
          file_system_name   = string
          file_path          = optional(string)
          folder_path        = optional(string)
        })), {})
        kusto_cluster = optional(map(object({
          name             = optional(string)
          kusto_cluster_id = string
        })), {})
        kusto_database = optional(map(object({
          name              = optional(string)
          kusto_database_id = string
        })), {})
      }), {})
    })), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_account"></a> [account](#output\_account)

Description: contains all data share account configuration

### <a name="output_blob_storage_datasets"></a> [blob\_storage\_datasets](#output\_blob\_storage\_datasets)

Description: contains all blob storage datasets

### <a name="output_data_lake_gen2_datasets"></a> [data\_lake\_gen2\_datasets](#output\_data\_lake\_gen2\_datasets)

Description: contains all data lake gen2 datasets

### <a name="output_kusto_cluster_datasets"></a> [kusto\_cluster\_datasets](#output\_kusto\_cluster\_datasets)

Description: contains all kusto cluster datasets

### <a name="output_kusto_database_datasets"></a> [kusto\_database\_datasets](#output\_kusto\_database\_datasets)

Description: contains all kusto database datasets

### <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments)

Description: contains all role assignments scoped to source resources

### <a name="output_shares"></a> [shares](#output\_shares)

Description: contains all data shares
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

The data share account uses a system assigned managed identity that needs read access on each source resource referenced by a dataset (for example Storage Blob Data Reader on a source storage account, or Contributor on a kusto cluster). The module exposes a `role_assignments` interface on the account object so these role assignments can be created in the same apply, scoped to the relevant source resource, with the data share account's identity as the principal. All dataset resources implicitly depend on these role assignments to avoid permission errors during dataset creation.

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-ds/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-ds" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/data-share/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/datashare/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/datashare)
