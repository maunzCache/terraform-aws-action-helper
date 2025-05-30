locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsglue.html

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

  prefix = "glue"

  access_level = {
    write = [
      "AuthorizeInboundIntegration",
      "BatchCreatePartition",
      "BatchDeleteConnection",
      "BatchDeletePartition",
      "BatchDeleteTable",
      "BatchDeleteTableVersion",
      "BatchStopJobRun",
      "BatchUpdatePartition",
      "CancelDataQualityRuleRecommendationRun",
      "CancelDataQualityRulesetEvaluationRun",
      "CancelMLTaskRun",
      "CancelStatement",
      "CreateBlueprint",
      "CreateCatalog",
      "CreateClassifier",
      "CreateColumnStatisticsTaskSettings",
      "CreateConnection",
      "CreateCrawler",
      "CreateCustomEntityType",
      "CreateDataQualityRuleset",
      "CreateDatabase",
      "CreateDevEndpoint",
      "CreateInboundIntegration",
      "CreateIntegration",
      "CreateIntegrationResourceProperty",
      "CreateIntegrationTableProperties",
      "CreateJob",
      "CreateMLTransform",
      "CreatePartition",
      "CreatePartitionIndex",
      "CreateRegistry",
      "CreateSchema",
      "CreateScript",
      "CreateSecurityConfiguration",
      "CreateSession",
      "CreateTable",
      "CreateTableOptimizer",
      "CreateTrigger",
      "CreateUsageProfile",
      "CreateUserDefinedFunction",
      "CreateWorkflow",
      "DeleteBlueprint",
      "DeleteCatalog",
      "DeleteClassifier",
      "DeleteColumnStatisticsForPartition",
      "DeleteColumnStatisticsForTable",
      "DeleteColumnStatisticsTaskSettings",
      "DeleteConnection",
      "DeleteCrawler",
      "DeleteCustomEntityType",
      "DeleteDataQualityRuleset",
      "DeleteDatabase",
      "DeleteDevEndpoint",
      "DeleteIntegration",
      "DeleteIntegrationTableProperties",
      "DeleteJob",
      "DeleteMLTransform",
      "DeletePartition",
      "DeletePartitionIndex",
      "DeleteRegistry",
      "DeleteSchema",
      "DeleteSchemaVersions",
      "DeleteSecurityConfiguration",
      "DeleteSession",
      "DeleteTable",
      "DeleteTableOptimizer",
      "DeleteTableVersion",
      "DeleteTrigger",
      "DeleteUsageProfile",
      "DeleteUserDefinedFunction",
      "DeleteWorkflow",
      "ImportCatalogToGlue",
      "ModifyIntegration",
      "NotifyEvent",
      "PassConnection",
      "PublishDataQuality",
      "PutDataCatalogEncryptionSettings",
      "PutDataQualityProfileAnnotation",
      "PutDataQualityStatisticAnnotation",
      "PutSchemaVersionMetadata",
      "PutWorkflowRunProperties",
      "RegisterSchemaVersion",
      "RemoveSchemaVersionMetadata",
      "ResetJobBookmark",
      "ResumeWorkflowRun",
      "RunStatement",
      "SendFeedback",
      "StartBlueprintRun",
      "StartColumnStatisticsTaskRun",
      "StartColumnStatisticsTaskRunSchedule",
      "StartCompletion",
      "StartCrawler",
      "StartCrawlerSchedule",
      "StartDataQualityRuleRecommendationRun",
      "StartDataQualityRulesetEvaluationRun",
      "StartExportLabelsTaskRun",
      "StartImportLabelsTaskRun",
      "StartJobRun",
      "StartJobUpgradeAnalysis",
      "StartMLEvaluationTaskRun",
      "StartMLLabelingSetGenerationTaskRun",
      "StartTrigger",
      "StartWorkflowRun",
      "StopColumnStatisticsTaskRun",
      "StopColumnStatisticsTaskRunSchedule",
      "StopCrawler",
      "StopCrawlerSchedule",
      "StopJobUpgradeAnalysis",
      "StopSession",
      "StopTrigger",
      "StopWorkflowRun",
      "UpdateBlueprint",
      "UpdateCatalog",
      "UpdateClassifier",
      "UpdateColumnStatisticsForPartition",
      "UpdateColumnStatisticsForTable",
      "UpdateColumnStatisticsTaskSettings",
      "UpdateConnection",
      "UpdateCrawler",
      "UpdateCrawlerSchedule",
      "UpdateDataQualityRuleset",
      "UpdateDatabase",
      "UpdateDevEndpoint",
      "UpdateIntegrationResourceProperty",
      "UpdateIntegrationTableProperties",
      "UpdateJob",
      "UpdateJobFromSourceControl",
      "UpdateMLTransform",
      "UpdatePartition",
      "UpdateRegistry",
      "UpdateSchema",
      "UpdateSourceControlFromJob",
      "UpdateTable",
      "UpdateTableOptimizer",
      "UpdateTrigger",
      "UpdateUsageProfile",
      "UpdateUserDefinedFunction",
      "UpdateWorkflow",
      "UpgradeJob",
      "UseMLTransforms"
    ]
    permissions_management = [
      "BatchGetStageFiles",
      "DeleteResourcePolicy",
      "DeregisterDataPreview",
      "DescribeConnectionType",
      "DescribeEntity",
      "GetDataPreviewStatement",
      "GetEnvironment",
      "GetExecutors",
      "GetExecutorsThreads",
      "GetLogParsingStatus",
      "GetNotebookInstanceStatus",
      "GetQueries",
      "GetQuery",
      "GetRecipeAction",
      "GetStage",
      "GetStageAttempt",
      "GetStageAttemptTaskList",
      "GetStageAttemptTaskSummary",
      "GetStageFiles",
      "GetStages",
      "GetStorage",
      "GetStorageUnit",
      "GlueNotebookAuthorize",
      "GlueNotebookRefreshCredentials",
      "ListConnectionTypes",
      "ListEntities",
      "PutResourcePolicy",
      "RefreshOAuth2Tokens",
      "RequestLogParsing",
      "RunDataPreviewStatement",
      "SendRecipeAction",
      "StartNotebook",
      "TerminateNotebook",
      "TestConnection",
      "UseGlueStudio"
    ]
    read = [
      "BatchGetBlueprints",
      "BatchGetCrawlers",
      "BatchGetCustomEntityTypes",
      "BatchGetDevEndpoints",
      "BatchGetJobs",
      "BatchGetPartition",
      "BatchGetTableOptimizer",
      "BatchGetTriggers",
      "BatchGetWorkflows",
      "CheckSchemaVersionValidity",
      "GetBlueprint",
      "GetBlueprintRun",
      "GetBlueprintRuns",
      "GetCatalog",
      "GetCatalogImportStatus",
      "GetCatalogs",
      "GetClassifier",
      "GetClassifiers",
      "GetColumnStatisticsForPartition",
      "GetColumnStatisticsForTable",
      "GetColumnStatisticsTaskRun",
      "GetColumnStatisticsTaskRuns",
      "GetColumnStatisticsTaskSettings",
      "GetCompletion",
      "GetConnection",
      "GetConnections",
      "GetCrawler",
      "GetCrawlerMetrics",
      "GetCrawlers",
      "GetCustomEntityType",
      "GetDashboardUrl",
      "GetDataCatalogEncryptionSettings",
      "GetDataQualityModel",
      "GetDataQualityModelResult",
      "GetDataQualityResult",
      "GetDataQualityRuleRecommendationRun",
      "GetDataQualityRuleset",
      "GetDataQualityRulesetEvaluationRun",
      "GetDatabase",
      "GetDatabases",
      "GetDataflowGraph",
      "GetDevEndpoint",
      "GetDevEndpoints",
      "GetEntityRecords",
      "GetGeneratedCode",
      "GetIntegrationResourceProperty",
      "GetIntegrationTableProperties",
      "GetJob",
      "GetJobBookmark",
      "GetJobRun",
      "GetJobRuns",
      "GetJobUpgradeAnalysis",
      "GetJobs",
      "GetMLTaskRun",
      "GetMLTransform",
      "GetMapping",
      "GetPartition",
      "GetPartitionIndexes",
      "GetPartitions",
      "GetPlan",
      "GetRegistry",
      "GetResourcePolicies",
      "GetResourcePolicy",
      "GetSchema",
      "GetSchemaByDefinition",
      "GetSchemaVersion",
      "GetSchemaVersionsDiff",
      "GetSecurityConfiguration",
      "GetSecurityConfigurations",
      "GetSession",
      "GetStatement",
      "GetTable",
      "GetTableOptimizer",
      "GetTableVersion",
      "GetTableVersions",
      "GetTables",
      "GetTags",
      "GetTrigger",
      "GetTriggers",
      "GetUsageProfile",
      "GetUserDefinedFunction",
      "GetUserDefinedFunctions",
      "GetWorkflow",
      "GetWorkflowRun",
      "GetWorkflowRunProperties",
      "GetWorkflowRuns",
      "ListColumnStatisticsTaskRuns",
      "SearchTables"
    ]
    list = [
      "DescribeInboundIntegrations",
      "DescribeIntegrations",
      "GetMLTaskRuns",
      "GetMLTransforms",
      "ListBlueprints",
      "ListCrawlers",
      "ListCrawls",
      "ListCustomEntityTypes",
      "ListDataQualityResults",
      "ListDataQualityRuleRecommendationRuns",
      "ListDataQualityRulesetEvaluationRuns",
      "ListDataQualityRulesets",
      "ListDevEndpoints",
      "ListJobUpgradeAnalyses",
      "ListJobs",
      "ListMLTransforms",
      "ListRegistries",
      "ListSchemaVersions",
      "ListSchemas",
      "ListSessions",
      "ListStatements",
      "ListTableOptimizerRuns",
      "ListTriggers",
      "ListUsageProfiles",
      "ListWorkflows",
      "QuerySchemaVersionMetadata"
    ]
    tagging = [
      "TagResource",
      "UntagResource"
    ]
  }
}
