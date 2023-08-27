locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonquicksight.html

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

  prefix = "quicksight"

  access_level = {
    write = [
      "AccountConfigurations",
      "CancelIngestion",
      "CreateAccountCustomization",
      "CreateAccountSubscription",
      "CreateAdmin",
      "CreateAnalysis",
      "CreateDashboard",
      "CreateDataSet",
      "CreateDataSource",
      "CreateEmailCustomizationTemplate",
      "CreateFolder",
      "CreateFolderMembership",
      "CreateGroup",
      "CreateGroupMembership",
      "CreateIAMPolicyAssignment",
      "CreateIngestion",
      "CreateNamespace",
      "CreateReader",
      "CreateRefreshSchedule",
      "CreateTemplate",
      "CreateTemplateAlias",
      "CreateTheme",
      "CreateThemeAlias",
      "CreateTopic",
      "CreateTopicRefreshSchedule",
      "CreateUser",
      "CreateVPCConnection",
      "DeleteAccountCustomization",
      "DeleteAccountSubscription",
      "DeleteAnalysis",
      "DeleteDashboard",
      "DeleteDataSet",
      "DeleteDataSetRefreshProperties",
      "DeleteDataSource",
      "DeleteEmailCustomizationTemplate",
      "DeleteFolder",
      "DeleteFolderMembership",
      "DeleteGroup",
      "DeleteGroupMembership",
      "DeleteIAMPolicyAssignment",
      "DeleteNamespace",
      "DeleteRefreshSchedule",
      "DeleteTemplate",
      "DeleteTemplateAlias",
      "DeleteTheme",
      "DeleteThemeAlias",
      "DeleteTopic",
      "DeleteTopicRefreshSchedule",
      "DeleteUser",
      "DeleteUserByPrincipalId",
      "DeleteVPCConnection",
      "DescribeCustomPermissions",
      "GenerateEmbedUrlForAnonymousUser",
      "GenerateEmbedUrlForRegisteredUser",
      "ListCustomPermissions",
      "PutDataSetRefreshProperties",
      "RegisterCustomerManagedKey",
      "RegisterUser",
      "RemoveCustomerManagedKey",
      "RestoreAnalysis",
      "ScopeDownPolicy",
      "SetGroupMapping",
      "StartAssetBundleExportJob",
      "StartAssetBundleImportJob",
      "StartDashboardSnapshotJob",
      "Subscribe",
      "Unsubscribe",
      "UpdateAccountCustomization",
      "UpdateAccountSettings",
      "UpdateAnalysis",
      "UpdateDashboard",
      "UpdateDashboardPublishedVersion",
      "UpdateDataSet",
      "UpdateDataSource",
      "UpdateEmailCustomizationTemplate",
      "UpdateFolder",
      "UpdateGroup",
      "UpdateIAMPolicyAssignment",
      "UpdateIpRestriction",
      "UpdatePublicSharingSettings",
      "UpdateRefreshSchedule",
      "UpdateResourcePermissions",
      "UpdateTemplate",
      "UpdateTemplateAlias",
      "UpdateTheme",
      "UpdateThemeAlias",
      "UpdateTopic",
      "UpdateTopicRefreshSchedule",
      "UpdateUser",
      "UpdateVPCConnection"
    ]
    permissions_management = [
      "CreateCustomPermissions",
      "DeleteCustomPermissions",
      "DescribeDataSetPermissions",
      "DescribeDataSourcePermissions",
      "DescribeTopicPermissions",
      "UpdateAnalysisPermissions",
      "UpdateCustomPermissions",
      "UpdateDashboardPermissions",
      "UpdateDataSetPermissions",
      "UpdateDataSourcePermissions",
      "UpdateFolderPermissions",
      "UpdateTemplatePermissions",
      "UpdateThemePermissions",
      "UpdateTopicPermissions"
    ]
    read = [
      "DescribeAccountCustomization",
      "DescribeAccountSettings",
      "DescribeAccountSubscription",
      "DescribeAnalysis",
      "DescribeAnalysisPermissions",
      "DescribeAssetBundleExportJob",
      "DescribeAssetBundleImportJob",
      "DescribeDashboard",
      "DescribeDashboardPermissions",
      "DescribeDashboardSnapshotJob",
      "DescribeDashboardSnapshotJobResult",
      "DescribeDataSet",
      "DescribeDataSetRefreshProperties",
      "DescribeDataSource",
      "DescribeEmailCustomizationTemplate",
      "DescribeFolder",
      "DescribeFolderPermissions",
      "DescribeFolderResolvedPermissions",
      "DescribeGroup",
      "DescribeGroupMembership",
      "DescribeIAMPolicyAssignment",
      "DescribeIngestion",
      "DescribeIpRestriction",
      "DescribeNamespace",
      "DescribeRefreshSchedule",
      "DescribeTemplate",
      "DescribeTemplateAlias",
      "DescribeTemplatePermissions",
      "DescribeTheme",
      "DescribeThemeAlias",
      "DescribeThemePermissions",
      "DescribeTopic",
      "DescribeTopicRefresh",
      "DescribeTopicRefreshSchedule",
      "DescribeUser",
      "DescribeVPCConnection",
      "GetAnonymousUserEmbedUrl",
      "GetAuthCode",
      "GetDashboardEmbedUrl",
      "GetGroupMapping",
      "GetSessionEmbedUrl",
      "ListFolderMembers",
      "ListTagsForResource",
      "PassDataSet",
      "PassDataSource",
      "SearchFolders"
    ]
    list = [
      "ListAnalyses",
      "ListAssetBundleExportJobs",
      "ListAssetBundleImportJobs",
      "ListCustomerManagedKeys",
      "ListDashboardVersions",
      "ListDashboards",
      "ListDataSets",
      "ListDataSources",
      "ListFolders",
      "ListGroupMemberships",
      "ListGroups",
      "ListIAMPolicyAssignments",
      "ListIAMPolicyAssignmentsForUser",
      "ListIngestions",
      "ListKMSKeysForUser",
      "ListNamespaces",
      "ListRefreshSchedules",
      "ListTemplateAliases",
      "ListTemplateVersions",
      "ListTemplates",
      "ListThemeAliases",
      "ListThemeVersions",
      "ListThemes",
      "ListTopicRefreshSchedules",
      "ListTopics",
      "ListUserGroups",
      "ListUsers",
      "ListVPCConnections",
      "SearchAnalyses",
      "SearchDashboards",
      "SearchDataSets",
      "SearchDataSources",
      "SearchDirectoryGroups",
      "SearchGroups",
      "SearchUsers"
    ]
    tagging = [
      "TagResource",
      "UntagResource"
    ]
  }
}
