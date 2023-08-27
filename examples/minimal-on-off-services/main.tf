locals {
  generate_dynamodb = contains(var.generate_services, "dynamodb")
  generate_ec2      = contains(var.generate_services, "ec2")

  // Helper to avoid output if actions should not be rendered
  generate_actions = {
    dynamodb = local.generate_dynamodb == true ? module.dynamodb[0].actions : {}
    ec2      = local.generate_ec2 == true ? module.ec2[0].actions : {}
  }

  // Output variable
  actions = {
    for service_name, service_actions in local.generate_actions : service_name => service_actions
    if length(service_actions) != 0
  }
}

module "dynamodb" {
  count = local.generate_dynamodb == true ? 1 : 0

  source = "../../modules/dynamodb"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

module "ec2" {
  count = local.generate_ec2 == true ? 1 : 0

  source = "../../modules/ec2"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}
