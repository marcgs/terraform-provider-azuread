data "azuread_client_config" "current" {}

locals {
  app_roles_example = {
    APP_ROLE1 = {
      description = "APP_ROLE1",
      value       = "app.role.1",
      permissions = ["7d42b37a-ecf6-4c60-bf18-47fc4aa2735a"]
    },
    APP_ROLE2 = {
      description = "APP_ROLE2",
      value       = "app.role.2",
      permissions = ["c93c22db-1047-4ef5-ad20-a708596109c2"]
    },
    APP_ROLE3 = {
      description = "APP_ROLE3",
      value       = "app.role.3",
      permissions = ["9452d3c8-62df-43b6-b791-875fd05f0fb2"]
    },
    APP_ROLE12 = {
      description = "APP_ROLE12",
      value       = "app.role.12",
      permissions = ["7d42b37a-ecf6-4c60-bf18-47fc4aa2735a", "c93c22db-1047-4ef5-ad20-a708596109c2"]
    },
    APP_ROLE13 = {
      description = "APP_ROLE13",
      value       = "app.role.13",
      permissions = ["7d42b37a-ecf6-4c60-bf18-47fc4aa2735a", "9452d3c8-62df-43b6-b791-875fd05f0fb2"]
    },
    APP_ROLE23 = {
      description = "APP_ROLE23",
      value       = "app.role.23",
      permissions = ["c93c22db-1047-4ef5-ad20-a708596109c2", "9452d3c8-62df-43b6-b791-875fd05f0fb2"]
    },
    APP_ROLE123 = {
      description = "APP_ROLE123",
      value       = "app.role.123",
      permissions = ["7d42b37a-ecf6-4c60-bf18-47fc4aa2735a", "c93c22db-1047-4ef5-ad20-a708596109c2", "9452d3c8-62df-43b6-b791-875fd05f0fb2"]
    },
  }
  list_of_assignments = flatten([
    for displayrolename, approle in local.app_roles_example : [
      for appvalue, groups in approle.permissions : {
        role_name = approle.value
        group     = groups
      }
    ]
  ])
}

resource "random_uuid" "uuid_example" {
  for_each = local.app_roles_example
}

resource "azuread_application" "example_app_reg" {
  display_name            = upper("dmp-hackaton-example")
  owners                  = [data.azuread_client_config.current.object_id]
  group_membership_claims = ["All"]

  dynamic "app_role" {
    for_each = local.app_roles_example
    content {
      allowed_member_types = ["User", "Application"]
      description          = app_role.value.description
      display_name         = app_role.key
      enabled              = true
      id                   = random_uuid.uuid_example[app_role.key].result
      value                = app_role.value.value
    }
  }
}

resource "azuread_service_principal" "example_sp" {
  application_id               = azuread_application.example_app_reg.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_app_role_assignment" "role_assignments" {
  for_each = { for assignment in local.list_of_assignments : "${assignment.role_name}.${assignment.group}" => assignment }

  app_role_id         = azuread_application.example_app_reg.app_role_ids[each.value.role_name]
  principal_object_id = each.value.group
  resource_object_id  = azuread_service_principal.example_sp.object_id
}

output "sp_display_name" {
  value = azuread_service_principal.example_sp.display_name
}