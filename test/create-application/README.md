<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~>1.0   |

## Inputs

| Name                                                                                                | Description                      | Type     | Default | Required |
| --------------------------------------------------------------------------------------------------- | -------------------------------- | -------- | ------- | :------: |
| <a name="input_azure_application_name"></a> [azure_application_name](#input_azure_application_name) | Name of the Azure AD application | `string` | n/a     |   yes    |

## Outputs

| Name                                                                             | Description           |
| -------------------------------------------------------------------------------- | --------------------- |
| <a name="output_client_id"></a> [client_id](#output_client_id)                   | AzureAD client ID     |
| <a name="output_subscription_id"></a> [subscription_id](#output_subscription_id) | Azure subscription ID |
| <a name="output_tenant_id"></a> [tenant_id](#output_tenant_id)                   | Azure tenant ID       |

<!-- END_TF_DOCS -->
