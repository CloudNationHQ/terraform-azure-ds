variable "account" {
  description = "describes data share account related configuration"
  type = object({
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

  validation {
    condition     = lookup(var.account, "location", null) != null || var.location != null
    error_message = "location must be set on var.account.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.account, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.account.resource_group_name or on the module-level var.resource_group_name."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
