locals {
  // Helper to avoid output if actions should not be rendered
  generate_actions = {
    ec2 = var.generate_ec2 == true ? module.ec2[0].actions : {}
  }

  // Output variable
  actions = {
    for service_name, service_actions in local.generate_actions : service_name => service_actions
    if length(service_actions) != 0 # Don't print actions that are not generated
  }
}

// TODO: Find a better way for invocing the code
// Maybe use some meta module with a map or something
module "ec2" {
  // TODO: I hate this count
  count = var.generate_ec2 == true ? 1 : 0

  source = "./modules/ec2"

  // TODO: Always inherits from root variables
  use_prefix     = var.use_prefix
  minify_strings = var.minify_strings
}
