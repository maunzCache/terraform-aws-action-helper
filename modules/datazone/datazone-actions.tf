locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazondatazone.html

  # TODO: Code below duplicates. Find a better way to DRY it.

  // Helper to filter out actions
  // Reads as: If filtering is empty, return current action. If filtering is provided, return action on matching condition.
  starts_with_filtered_actions = {
    write                  = distinct([for action in local.access_level.write : (length(var.filtering.starts_with) == 0) || startswith(action, var.filtering.starts_with) ? action : ""])
    permissions_management = distinct([for action in local.access_level.permissions_management : (length(var.filtering.starts_with) == 0) || startswith(action, var.filtering.starts_with) ? action : ""])
    read                   = distinct([for action in local.access_level.read : (length(var.filtering.starts_with) == 0) || startswith(action, var.filtering.starts_with) ? action : ""])
    list                   = distinct([for action in local.access_level.list : (length(var.filtering.starts_with) == 0) || startswith(action, var.filtering.starts_with) ? action : ""])
    tagging                = distinct([for action in local.access_level.tagging : (length(var.filtering.starts_with) == 0) || startswith(action, var.filtering.starts_with) ? action : ""])
  }

  contains_filtered_actions = {
    write                  = distinct([for action in local.starts_with_filtered_actions.write : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    permissions_management = distinct([for action in local.starts_with_filtered_actions.permissions_management : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    read                   = distinct([for action in local.starts_with_filtered_actions.read : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    list                   = distinct([for action in local.starts_with_filtered_actions.list : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
    tagging                = distinct([for action in local.starts_with_filtered_actions.tagging : (length(var.filtering.contains) == 0) || (replace(action, var.filtering.contains, "") != action) == true ? action : ""])
  }

  ends_with_filtered_actions = {
    write                  = distinct([for action in local.contains_filtered_actions.write : (length(var.filtering.ends_with) == 0) || endswith(action, var.filtering.ends_with) ? action : ""])
    permissions_management = distinct([for action in local.contains_filtered_actions.permissions_management : (length(var.filtering.ends_with) == 0) || endswith(action, var.filtering.ends_with) ? action : ""])
    read                   = distinct([for action in local.contains_filtered_actions.read : (length(var.filtering.ends_with) == 0) || endswith(action, var.filtering.ends_with) ? action : ""])
    list                   = distinct([for action in local.contains_filtered_actions.list : (length(var.filtering.ends_with) == 0) || endswith(action, var.filtering.ends_with) ? action : ""])
    tagging                = distinct([for action in local.contains_filtered_actions.tagging : (length(var.filtering.ends_with) == 0) || endswith(action, var.filtering.ends_with) ? action : ""])
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

  prefix = "datazone"

  access_level = {
    write = [
      "AcceptPredictions",
      "AcceptSubscriptionRequest",
      "AddEntityOwner",
      "AddPolicyGrant",
      "AssociateEnvironmentRole",
      "BatchDeleteLinkedTypes",
      "BatchPutLinkedTypes",
      "CancelMetadataGenerationRun",
      "CancelSubscription",
      "CreateAsset",
      "CreateAssetFilter",
      "CreateAssetRevision",
      "CreateAssetType",
      "CreateConnection",
      "CreateDataProduct",
      "CreateDataProductRevision",
      "CreateDataSource",
      "CreateDomain",
      "CreateDomainUnit",
      "CreateEnvironment",
      "CreateEnvironmentAction",
      "CreateEnvironmentBlueprint",
      "CreateEnvironmentProfile",
      "CreateFormType",
      "CreateGlossary",
      "CreateGlossaryTerm",
      "CreateGroupProfile",
      "CreateListingChangeSet",
      "CreateProject",
      "CreateProjectMembership",
      "CreateProjectProfile",
      "CreateRule",
      "CreateSubscriptionGrant",
      "CreateSubscriptionRequest",
      "CreateSubscriptionTarget",
      "CreateUserProfile",
      "DeleteAsset",
      "DeleteAssetFilter",
      "DeleteAssetType",
      "DeleteConnection",
      "DeleteDataProduct",
      "DeleteDataSource",
      "DeleteDomain",
      "DeleteDomainUnit",
      "DeleteEnvironment",
      "DeleteEnvironmentAction",
      "DeleteEnvironmentBlueprint",
      "DeleteEnvironmentBlueprintConfiguration",
      "DeleteEnvironmentProfile",
      "DeleteFormType",
      "DeleteGlossary",
      "DeleteGlossaryTerm",
      "DeleteListing",
      "DeleteProject",
      "DeleteProjectMembership",
      "DeleteProjectProfile",
      "DeleteRule",
      "DeleteSubscriptionGrant",
      "DeleteSubscriptionRequest",
      "DeleteSubscriptionTarget",
      "DeleteTimeSeriesDataPoints",
      "DisassociateEnvironmentRole",
      "PostLineageEvent",
      "PostTimeSeriesDataPoints",
      "ProvisionDomain",
      "PutEnvironmentBlueprintConfiguration",
      "RefreshToken",
      "RejectPredictions",
      "RejectSubscriptionRequest",
      "RemoveEntityOwner",
      "RemovePolicyGrant",
      "RevokeSubscription",
      "SsoLogin",
      "SsoLogout",
      "StartDataSourceRun",
      "StartMetadataGenerationRun",
      "StopMetadataGenerationRun",
      "UpdateAssetFilter",
      "UpdateConnection",
      "UpdateDataSource",
      "UpdateDataSourceRunActivities",
      "UpdateDomain",
      "UpdateDomainUnit",
      "UpdateEnvironment",
      "UpdateEnvironmentAction",
      "UpdateEnvironmentBlueprint",
      "UpdateEnvironmentConfiguration",
      "UpdateEnvironmentDeploymentStatus",
      "UpdateEnvironmentProfile",
      "UpdateGlossary",
      "UpdateGlossaryTerm",
      "UpdateGroupProfile",
      "UpdateProject",
      "UpdateProjectProfile",
      "UpdateRule",
      "UpdateSubscriptionGrantStatus",
      "UpdateSubscriptionRequest",
      "UpdateSubscriptionTarget",
      "UpdateUserProfile",
      "ValidatePassRole"
    ]
    permissions_management = [
      "DeleteDomainSharingPolicy",
      "GetIamPortalLoginUrl",
      "PutDomainSharingPolicy"
    ]
    read = [
      "GetAsset",
      "GetAssetFilter",
      "GetAssetType",
      "GetConnection",
      "GetDataProduct",
      "GetDataSource",
      "GetDataSourceRun",
      "GetDomain",
      "GetDomainExecutionRoleCredentials",
      "GetDomainSharingPolicy",
      "GetDomainUnit",
      "GetEnvironment",
      "GetEnvironmentAction",
      "GetEnvironmentActionLink",
      "GetEnvironmentBlueprint",
      "GetEnvironmentBlueprintConfiguration",
      "GetEnvironmentCredentials",
      "GetEnvironmentProfile",
      "GetFormType",
      "GetGlossary",
      "GetGlossaryTerm",
      "GetGroupProfile",
      "GetJobRun",
      "GetLineageEvent",
      "GetLineageNode",
      "GetListing",
      "GetMetadataGenerationRun",
      "GetProject",
      "GetProjectProfile",
      "GetRule",
      "GetSubscription",
      "GetSubscriptionEligibility",
      "GetSubscriptionGrant",
      "GetSubscriptionRequestDetails",
      "GetSubscriptionTarget",
      "GetTimeSeriesDataPoint",
      "GetUpdateEligibility",
      "GetUserProfile",
      "ListTagsForResource"
    ]
    list = [
      "ListAccountEnvironments",
      "ListAssetFilters",
      "ListAssetRevisions",
      "ListConnections",
      "ListDataProductRevisions",
      "ListDataSourceRunActivities",
      "ListDataSourceRuns",
      "ListDataSources",
      "ListDomainUnitsForParent",
      "ListDomains",
      "ListEntityOwners",
      "ListEnvironmentActions",
      "ListEnvironmentBlueprintConfigurationSummaries",
      "ListEnvironmentBlueprintConfigurations",
      "ListEnvironmentBlueprints",
      "ListEnvironmentProfiles",
      "ListEnvironments",
      "ListGroupsForUser",
      "ListJobRuns",
      "ListLineageEvents",
      "ListLineageNodeHistory",
      "ListLinkedTypes",
      "ListMetadataGenerationRuns",
      "ListNotifications",
      "ListPolicyGrants",
      "ListProjectMemberships",
      "ListProjectProfiles",
      "ListProjects",
      "ListRules",
      "ListSubscriptionGrants",
      "ListSubscriptionRequests",
      "ListSubscriptionTargets",
      "ListSubscriptions",
      "ListTimeSeriesDataPoints",
      "ListWarehouseMetadata",
      "Search",
      "SearchGroupProfiles",
      "SearchListings",
      "SearchRules",
      "SearchTypes",
      "SearchUserProfiles"
    ]
    tagging = [
      "TagResource",
      "UntagResource"
    ]
  }
}
