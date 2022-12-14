# Role assignment issue analysis

This folder contains terraform configuration to reproduce issue [#763](https://github.com/hashicorp/terraform-provider-azuread/issues/763). 

A provisioning of an app registration with ~100 role assignments was run in a loop for over an hour, but still the issue could not be reproduced. 

## Steps to run

1. In the `app_roles_json` folder run:
      ```bash
        terraform init
        terraform plan && terraform apply -auto-approve
      ```
      This will generate a `roles.json` file with ~100 entries (you can change the amount of entries by adapting the `count` variable at the beginning of `main.tf`)


2. In the `dmp-hackaton` folder run:
      ```bash
        terraform init
        terraform plan && terraform apply -auto-approve
      ```
      This will provision an app registration with a service principal and assign the roles created in the previous step.


3. If you desire to repeat the test you can destroy the infra with `terraform destroy` and rerun step 2.

