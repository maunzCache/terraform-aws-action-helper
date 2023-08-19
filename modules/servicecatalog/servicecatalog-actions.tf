locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsservicecatalog.html

  # TODO: Code below duplicates. Find a better way to DRY it.

  // Helper to filter out actions
  // Based on https://github.com/hashicorp/terraform/issues/28209
  // Reads as: If filtering is empty use action or if action - after removing prefix - is not longer the action, return the action
  starts_with_filtered_actions = {
    write                  = distinct([for action in local.access_level.write : (length(var.filtering.starts_with) == 0) || (trimprefix(action, var.filtering.starts_with) != action) == true ? action : ""])
    permissions_management = distinct([for action in local.access_level.permissions_management : (length(var.filtering.starts_with) == 0) || (trimprefix(action, var.filtering.starts_with) != action) == true ? action : ""])
    read                   = distinct([for action in local.access_level.read : (length(var.filtering.starts_with) == 0) || (trimprefix(action, var.filtering.starts_with) != action) == true ? action : ""])
    list                   = distinct([for action in local.access_level.list : (length(var.filtering.starts_with) == 0) || (trimprefix(action, var.filtering.starts_with) != action) == true ? action : ""])
    tagging                = distinct([for action in local.access_level.tagging : (length(var.filtering.starts_with) == 0) || (trimprefix(action, var.filtering.starts_with) != action) == true ? action : ""])
  }

  contains_filtered_actions = {
    write                  = distinct([for action in local.starts_with_filtered_actions.write : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    permissions_management = distinct([for action in local.starts_with_filtered_actions.permissions_management : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    read                   = distinct([for action in local.starts_with_filtered_actions.read : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    list                   = distinct([for action in local.starts_with_filtered_actions.list : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    tagging                = distinct([for action in local.starts_with_filtered_actions.tagging : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
  }

  ends_with_filtered_actions = {
    write                  = distinct([for action in local.contains_filtered_actions.write : (length(var.filtering.ends_with) == 0) || (trimsuffix(action, var.filtering.ends_with) != action) == true ? action : ""])
    permissions_management = distinct([for action in local.contains_filtered_actions.permissions_management : (length(var.filtering.ends_with) == 0) || (trimsuffix(action, var.filtering.ends_with) != action) == true ? action : ""])
    read                   = distinct([for action in local.contains_filtered_actions.read : (length(var.filtering.ends_with) == 0) || (trimsuffix(action, var.filtering.ends_with) != action) == true ? action : ""])
    list                   = distinct([for action in local.contains_filtered_actions.list : (length(var.filtering.ends_with) == 0) || (trimsuffix(action, var.filtering.ends_with) != action) == true ? action : ""])
    tagging                = distinct([for action in local.contains_filtered_actions.tagging : (length(var.filtering.ends_with) == 0) || (trimsuffix(action, var.filtering.ends_with) != action) == true ? action : ""])
  }

  // Remove entries that are not matched by the filter.
  // Because of typing, value is checked for empty string
  sanitized_filtered_actions = {
    write                  = [for action_name in local.ends_with_filtered_actions.write : action_name if length(action_name) != 0]
    permissions_management = [for action_name in local.ends_with_filtered_actions.permissions_management : action_name if length(action_name) != 0]
    read                   = [for action_name in local.ends_with_filtered_actions.read : action_name if length(action_name) != 0]
    list                   = [for action_name in local.ends_with_filtered_actions.list : action_name if length(action_name) != 0]
    tagging                = [for action_name in local.ends_with_filtered_actions.tagging : action_name if length(action_name) != 0]
  }

  // Helper to minifying out actions
  minified_actions = {
    write                  = distinct([for action in local.sanitized_filtered_actions.write : var.minify_strings == true ? replace(action, var.minify_regex, var.minify_replacement) : action])
    permissions_management = distinct([for action in local.sanitized_filtered_actions.permissions_management : var.minify_strings == true ? replace(action, var.minify_regex, var.minify_replacement) : action])
    read                   = distinct([for action in local.sanitized_filtered_actions.read : var.minify_strings == true ? replace(action, var.minify_regex, var.minify_replacement) : action])
    list                   = distinct([for action in local.sanitized_filtered_actions.list : var.minify_strings == true ? replace(action, var.minify_regex, var.minify_replacement) : action])
    tagging                = distinct([for action in local.sanitized_filtered_actions.tagging : var.minify_strings == true ? replace(action, var.minify_regex, var.minify_replacement) : action])
  }

  actions = {
    write                  = [for action in local.minified_actions.write : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    permissions_management = [for action in local.minified_actions.permissions_management : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    read                   = [for action in local.minified_actions.read : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    list                   = [for action in local.minified_actions.list : var.use_prefix == true ? "${local.prefix}:${action}" : action]
    tagging                = [for action in local.minified_actions.tagging : var.use_prefix == true ? "${local.prefix}:${action}" : action]
  }

  prefix = "servicecatalog"

  access_level = {
    write                  = [
    "AcceptPortfolioShare",
    "AssociateAttributeGroup",
    "AssociateBudgetWithResource",
    "AssociatePrincipalWithPortfolio",
    "AssociateProductWithPortfolio",
    "AssociateResource",
    "AssociateServiceActionWithProvisioningArtifact",
    "AssociateTagOptionWithResource",
    "BatchAssociateServiceActionWithProvisioningArtifact",
    "BatchDisassociateServiceActionFromProvisioningArtifact",
    "CopyProduct",
    "CreateApplication",
    "CreateAttributeGroup",
    "CreateConstraint",
    "CreatePortfolio",
    "CreateProduct",
    "CreateProvisionedProductPlan",
    "CreateProvisioningArtifact",
    "CreateServiceAction",
    "CreateTagOption",
    "DeleteApplication",
    "DeleteAttributeGroup",
    "DeleteConstraint",
    "DeletePortfolio",
    "DeleteProduct",
    "DeleteProvisionedProductPlan",
    "DeleteProvisioningArtifact",
    "DeleteServiceAction",
    "DeleteTagOption",
    "DisableAWSOrganizationsAccess",
    "DisassociateAttributeGroup",
    "DisassociateBudgetFromResource",
    "DisassociatePrincipalFromPortfolio",
    "DisassociateProductFromPortfolio",
    "DisassociateResource",
    "DisassociateServiceActionFromProvisioningArtifact",
    "DisassociateTagOptionFromResource",
    "EnableAWSOrganizationsAccess",
    "ExecuteProvisionedProductPlan",
    "ExecuteProvisionedProductServiceAction",
    "ImportAsProvisionedProduct",
    "NotifyProvisionProductEngineWorkflowResult",
    "NotifyTerminateProvisionedProductEngineWorkflowResult",
    "NotifyUpdateProvisionedProductEngineWorkflowResult",
    "ProvisionProduct",
    "PutConfiguration",
    "RejectPortfolioShare",
    "SyncResource",
    "TerminateProvisionedProduct",
    "UpdateApplication",
    "UpdateAttributeGroup",
    "UpdateConstraint",
    "UpdatePortfolio",
    "UpdateProduct",
    "UpdateProvisionedProduct",
    "UpdateProvisionedProductProperties",
    "UpdateProvisioningArtifact",
    "UpdateServiceAction",
    "UpdateTagOption"
]
    permissions_management = [
    "CreatePortfolioShare",
    "DeletePortfolioShare",
    "UpdatePortfolioShare"
]
    read                   = [
    "DescribeConstraint",
    "DescribeCopyProductStatus",
    "DescribePortfolio",
    "DescribePortfolioShareStatus",
    "DescribeProduct",
    "DescribeProductAsAdmin",
    "DescribeProductView",
    "DescribeProvisionedProduct",
    "DescribeProvisionedProductPlan",
    "DescribeProvisioningArtifact",
    "DescribeProvisioningParameters",
    "DescribeRecord",
    "DescribeServiceAction",
    "DescribeServiceActionExecutionParameters",
    "DescribeTagOption",
    "GetAWSOrganizationsAccessStatus",
    "GetApplication",
    "GetAssociatedResource",
    "GetAttributeGroup",
    "GetConfiguration",
    "GetProvisionedProductOutputs",
    "ListTagsForResource"
]
    list                   = [
    "DescribePortfolioShares",
    "ListAcceptedPortfolioShares",
    "ListApplications",
    "ListAssociatedAttributeGroups",
    "ListAssociatedResources",
    "ListAttributeGroups",
    "ListAttributeGroupsForApplication",
    "ListBudgetsForResource",
    "ListConstraintsForPortfolio",
    "ListLaunchPaths",
    "ListOrganizationPortfolioAccess",
    "ListPortfolioAccess",
    "ListPortfolios",
    "ListPortfoliosForProduct",
    "ListPrincipalsForPortfolio",
    "ListProvisionedProductPlans",
    "ListProvisioningArtifacts",
    "ListProvisioningArtifactsForServiceAction",
    "ListRecordHistory",
    "ListResourcesForTagOption",
    "ListServiceActions",
    "ListServiceActionsForProvisioningArtifact",
    "ListStackInstancesForProvisionedProduct",
    "ListTagOptions",
    "ScanProvisionedProducts",
    "SearchProducts",
    "SearchProductsAsAdmin",
    "SearchProvisionedProducts"
]
    tagging                = [
    "TagResource",
    "UntagResource"
]
  }
}