locals {
  count = 400
}

data "template_file" "app_roles" {
  count    = local.count
  template = <<EOF
  "APP_ROLE${count.index+1}": {
    "description": "APP_ROLE${count.index+1}",
    "value": "app.role.${count.index+1}",
    "permissions": [
        "${random_shuffle.groups.result[count.index]}"
    ]
  }
EOF
}

resource "random_shuffle" "groups" {
  input        = ["7d42b37a-ecf6-4c60-bf18-47fc4aa2735a", "c93c22db-1047-4ef5-ad20-a708596109c2", "9452d3c8-62df-43b6-b791-875fd05f0fb2"]
  result_count = local.count
}

resource "local_file" "output_file" {
  content  = "{${join(",", data.template_file.app_roles.*.rendered)}}"
  filename = "roles.json"
}