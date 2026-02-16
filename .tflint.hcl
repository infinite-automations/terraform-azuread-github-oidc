tflint {
  required_version = ">= 0.51"
}

config {
    call_module_type = "all"
    force = false
    disabled_by_default = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
    enabled = true
    version = "0.31.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}