# Bootstrap repository for testing

1. Create a PAT with the following repository permissions:

- Dependabot secrets: Read and write
- Environments: Read and write
- Secrets: Read and write

2. Execute the following script:

```bash
# set env
export ARM_SUBSCRIPTION_ID=<tenant id>
export ARM_TENANT_ID=<subscription id>
export TF_VAR_github_token=<github PAT>

# deploy
terraform init
terraform apply -auto-approve
```

3. As admin: Got to the [Entra ID portal](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade/quickStartType~/null/sourceType/Microsoft_AAD_IAM) and grant consent to the requested application API permissions for the new application


## Terraform Docs

<!-- BEGIN_TF_DOCS -->


### main.tf

```hcl
terraform {
  required_version = "~>1.0"
}

variable "github_token" {
  description = "GitHub token for writing the secret"
  type        = string
  sensitive   = true
  default     = null
}

module "github-oidc" {
  source = "../examples/full"
  azure_application_api_access = [{
    api_name          = "MicrosoftGraph"
    role_permissions  = ["Application.ReadWrite.All"]
    scope_permissions = []
  }]
  azure_service_principal_subscription_roles = ["Owner"]
  github_repository_branches                 = ["main"]
  github_repository_tags                     = []
  github_repository_environments             = ["main", "pr"]
  github_repository_pull_request             = true
  github_token                               = var.github_token
}
```

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |





### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub token for writing the secret | `string` | `null` | no |




<!-- END_TF_DOCS -->