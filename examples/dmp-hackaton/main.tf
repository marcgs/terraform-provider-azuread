data "azuread_client_config" "current" {}

locals {
  app_roles_example = jsondecode(file("roles.json"))
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