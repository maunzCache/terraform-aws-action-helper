locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/{{ cookiecutter.service_docs_page_name }}.html

  # TODO: Code below duplicates. Find a better way to DRY it.

  minify_regex       = "/([A-Z]^[A-Z]+).+/"
  minify_replacement = "$1*"

  // Helper to filter out actions
  minified_actions = {
    write                  = distinct([for action in local.access_level.write : var.minify_strings == true ? replace(action, local.minify_regex, local.minify_replacement) : action])
    permissions_management = distinct([for action in local.access_level.permissions_management : var.minify_strings == true ? replace(action, local.minify_regex, local.minify_replacement) : action])
    read                   = distinct([for action in local.access_level.read : var.minify_strings == true ? replace(action, local.minify_regex, local.minify_replacement) : action])
    list                   = distinct([for action in local.access_level.list : var.minify_strings == true ? replace(action, local.minify_regex, local.minify_replacement) : action])
    tagging                = distinct([for action in local.access_level.tagging : var.minify_strings == true ? replace(action, local.minify_regex, local.minify_replacement) : action])
  }

  actions = {
    write                  = [for action in local.minified_actions.write : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    permissions_management = [for action in local.minified_actions.permissions_management : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    read                   = [for action in local.minified_actions.read : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    list                   = [for action in local.minified_actions.list : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    tagging                = [for action in local.minified_actions.tagging : var.use_prefix == true ? "${local.prefix}:${action}" : action]
  }

  prefix = "{{cookiecutter.service_prefix}}"

  access_level = {
    write                  = {{ cookiecutter.service_actions.write | jsonify }}
    permissions_management = {{ cookiecutter.service_actions.permissions_management | jsonify }}
    read                   = {{ cookiecutter.service_actions.read | jsonify }}
    list                   = {{ cookiecutter.service_actions.list | jsonify }}
    tagging                = {{ cookiecutter.service_actions.tagging | jsonify }}
  }
}
