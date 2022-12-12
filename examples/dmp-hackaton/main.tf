data "azuread_client_config" "current" {}

resource "azuread_application" "internal" {
  display_name = "dmp-hackaton-internal-3"
  owners                  = [data.azuread_client_config.current.object_id]

  app_role {
    allowed_member_types = ["Application"]
    description          = "Apps can query the database"
    display_name         = "Query"
    enabled              = true
    id                   = "00000000-0000-0000-0000-111111111111"
    value                = "Query.All"
  }
}

resource "azuread_service_principal" "internal" {
  application_id = azuread_application.internal.application_id
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application" "example" {
  display_name = "dmp-hackaton-example"
  owners                       = [data.azuread_client_config.current.object_id]

  required_resource_access {
    resource_app_id = azuread_application.internal.application_id

    resource_access {
      id   = azuread_service_principal.internal.app_role_ids["Query.All"]
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "example" {
  application_id = azuread_application.example.application_id
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_app_role_assignment" "example" {
  app_role_id         = azuread_service_principal.internal.app_role_ids["Query.All"]
  principal_object_id = azuread_service_principal.example.object_id
  resource_object_id  = azuread_service_principal.internal.object_id
}