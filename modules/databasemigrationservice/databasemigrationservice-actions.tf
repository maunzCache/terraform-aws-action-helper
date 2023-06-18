locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsdatabasemigrationservice.html

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

  prefix = "dms"

  access_level = {
    write                  = [
    "ApplyPendingMaintenanceAction",
    "AssociateExtensionPack",
    "BatchStartRecommendations",
    "CancelMetadataModelAssessment",
    "CancelMetadataModelConversion",
    "CancelMetadataModelExport",
    "CancelReplicationTaskAssessmentRun",
    "CreateDataMigration",
    "CreateDataProvider",
    "CreateEndpoint",
    "CreateEventSubscription",
    "CreateFleetAdvisorCollector",
    "CreateInstanceProfile",
    "CreateMigrationProject",
    "CreateReplicationConfig",
    "CreateReplicationInstance",
    "CreateReplicationSubnetGroup",
    "CreateReplicationTask",
    "DeleteCertificate",
    "DeleteConnection",
    "DeleteDataMigration",
    "DeleteDataProvider",
    "DeleteEndpoint",
    "DeleteEventSubscription",
    "DeleteFleetAdvisorCollector",
    "DeleteFleetAdvisorDatabases",
    "DeleteInstanceProfile",
    "DeleteMigrationProject",
    "DeleteReplicationConfig",
    "DeleteReplicationInstance",
    "DeleteReplicationSubnetGroup",
    "DeleteReplicationTask",
    "DeleteReplicationTaskAssessmentRun",
    "DisassociateExtensionPack",
    "ExportMetadataModelAssessment",
    "ImportCertificate",
    "ModifyDataMigration",
    "ModifyEndpoint",
    "ModifyEventSubscription",
    "ModifyFleetAdvisorCollector",
    "ModifyFleetAdvisorCollectorStatuses",
    "ModifyReplicationConfig",
    "ModifyReplicationInstance",
    "ModifyReplicationSubnetGroup",
    "ModifyReplicationTask",
    "MoveReplicationTask",
    "RebootReplicationInstance",
    "RefreshSchemas",
    "ReloadReplicationTables",
    "ReloadTables",
    "RunFleetAdvisorLsaAnalysis",
    "StartDataMigration",
    "StartMetadataModelAssessment",
    "StartMetadataModelConversion",
    "StartMetadataModelExportAsScripts",
    "StartMetadataModelExportToTarget",
    "StartMetadataModelImport",
    "StartRecommendations",
    "StartReplication",
    "StartReplicationTask",
    "StartReplicationTaskAssessment",
    "StartReplicationTaskAssessmentRun",
    "StopDataMigration",
    "StopReplication",
    "StopReplicationTask",
    "UpdateConversionConfiguration",
    "UpdateDataProvider",
    "UpdateInstanceProfile",
    "UpdateMigrationProject",
    "UpdateSubscriptionsToEventBridge",
    "UploadFileMetadataList"
]
    permissions_management = []
    read                   = [
    "DescribeAccountAttributes",
    "DescribeApplicableIndividualAssessments",
    "DescribeCertificates",
    "DescribeConnections",
    "DescribeDataMigrations",
    "DescribeEndpointSettings",
    "DescribeEndpointTypes",
    "DescribeEndpoints",
    "DescribeEventCategories",
    "DescribeEventSubscriptions",
    "DescribeEvents",
    "DescribeFleetAdvisorCollectors",
    "DescribeFleetAdvisorDatabases",
    "DescribeFleetAdvisorLsaAnalysis",
    "DescribeFleetAdvisorSchemaObjectSummary",
    "DescribeFleetAdvisorSchemas",
    "DescribeOrderableReplicationInstances",
    "DescribePendingMaintenanceActions",
    "DescribeRecommendationLimitations",
    "DescribeRecommendations",
    "DescribeRefreshSchemasStatus",
    "DescribeReplicationConfigs",
    "DescribeReplicationInstanceTaskLogs",
    "DescribeReplicationInstances",
    "DescribeReplicationSubnetGroups",
    "DescribeReplicationTableStatistics",
    "DescribeReplicationTaskAssessmentResults",
    "DescribeReplicationTaskAssessmentRuns",
    "DescribeReplicationTaskIndividualAssessments",
    "DescribeReplicationTasks",
    "DescribeReplications",
    "DescribeSchemas",
    "DescribeTableStatistics",
    "GetMetadataModel",
    "ListDataProviders",
    "ListExtensionPacks",
    "ListInstanceProfiles",
    "ListMetadataModelAssessmentActionItems",
    "ListMetadataModelAssessments",
    "ListMetadataModelConversions",
    "ListMetadataModelExports",
    "ListMigrationProjects",
    "ListTagsForResource",
    "TestConnection"
]
    list                   = []
    tagging                = [
    "AddTagsToResource",
    "RemoveTagsFromResource"
]
  }
}
