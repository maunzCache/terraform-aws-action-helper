// TODO: Generate this file as well based on the submodules that are available
locals {
  generate_dynamodb = contains(var.generate_services, "dynamodb")
  generate_ec2      = contains(var.generate_services, "ec2")
  generate_iam      = contains(var.generate_services, "iam")

  // Helper to avoid output if actions should not be rendered
  generate_actions = {
    dynamodb = local.generate_dynamodb == true ? module.dynamodb[0].actions : {}
    ec2      = local.generate_ec2 == true ? module.ec2[0].actions : {}
    iam      = local.generate_iam == true ? module.iam[0].actions : {}
  }

  // Output variable
  actions = {
    for service_name, service_actions in local.generate_actions : service_name => service_actions
    if length(service_actions) != 0
  }
}

# TODO: If ends_with and minify_strings is used, then the regex should look from the end and not the start
# If not then this happens
# ends_with = "Instances" -> ["ec2:StartInstances", "ec2:StopInstances"]
# => ["ec2:Start*", "ec2:Stop*"]
# but we may want
# => ["ec2:*Instances"]
# Contains is an even harder case so just write a fat note like "don't use the defaults!"

module "dynamodb" {
  count = local.generate_dynamodb == true ? 1 : 0

  source = "./modules/dynamodb"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

module "ec2" {
  count = local.generate_ec2 == true ? 1 : 0

  source = "./modules/ec2"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

module "iam" {
  count = local.generate_iam == true ? 1 : 0

  source = "./modules/iam"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}
