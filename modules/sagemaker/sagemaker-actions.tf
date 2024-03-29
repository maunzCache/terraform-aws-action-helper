locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonsagemaker.html

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

  prefix = "sagemaker"

  access_level = {
    write = [
      "AddAssociation",
      "AssociateTrialComponent",
      "BatchPutMetrics",
      "CreateAction",
      "CreateAlgorithm",
      "CreateApp",
      "CreateAppImageConfig",
      "CreateArtifact",
      "CreateAutoMLJob",
      "CreateAutoMLJobV2",
      "CreateCodeRepository",
      "CreateCompilationJob",
      "CreateContext",
      "CreateDataQualityJobDefinition",
      "CreateDeviceFleet",
      "CreateDomain",
      "CreateEdgeDeploymentPlan",
      "CreateEdgeDeploymentStage",
      "CreateEdgePackagingJob",
      "CreateEndpoint",
      "CreateEndpointConfig",
      "CreateExperiment",
      "CreateFeatureGroup",
      "CreateFlowDefinition",
      "CreateHub",
      "CreateHumanTaskUi",
      "CreateHyperParameterTuningJob",
      "CreateImage",
      "CreateImageVersion",
      "CreateInferenceExperiment",
      "CreateInferenceRecommendationsJob",
      "CreateLabelingJob",
      "CreateLineageGroupPolicy",
      "CreateModel",
      "CreateModelBiasJobDefinition",
      "CreateModelCard",
      "CreateModelCardExportJob",
      "CreateModelExplainabilityJobDefinition",
      "CreateModelPackage",
      "CreateModelPackageGroup",
      "CreateModelQualityJobDefinition",
      "CreateMonitoringSchedule",
      "CreateNotebookInstance",
      "CreateNotebookInstanceLifecycleConfig",
      "CreatePipeline",
      "CreatePresignedDomainUrl",
      "CreatePresignedNotebookInstanceUrl",
      "CreateProcessingJob",
      "CreateProject",
      "CreateSharedModel",
      "CreateSpace",
      "CreateStudioLifecycleConfig",
      "CreateTrainingJob",
      "CreateTransformJob",
      "CreateTrial",
      "CreateTrialComponent",
      "CreateUserProfile",
      "CreateWorkforce",
      "CreateWorkteam",
      "DeleteAction",
      "DeleteAlgorithm",
      "DeleteApp",
      "DeleteAppImageConfig",
      "DeleteArtifact",
      "DeleteAssociation",
      "DeleteCodeRepository",
      "DeleteContext",
      "DeleteDataQualityJobDefinition",
      "DeleteDeviceFleet",
      "DeleteDomain",
      "DeleteEdgeDeploymentPlan",
      "DeleteEdgeDeploymentStage",
      "DeleteEndpoint",
      "DeleteEndpointConfig",
      "DeleteExperiment",
      "DeleteFeatureGroup",
      "DeleteFlowDefinition",
      "DeleteHub",
      "DeleteHubContent",
      "DeleteHumanLoop",
      "DeleteHumanTaskUi",
      "DeleteImage",
      "DeleteImageVersion",
      "DeleteInferenceExperiment",
      "DeleteLineageGroupPolicy",
      "DeleteModel",
      "DeleteModelBiasJobDefinition",
      "DeleteModelCard",
      "DeleteModelExplainabilityJobDefinition",
      "DeleteModelPackage",
      "DeleteModelPackageGroup",
      "DeleteModelPackageGroupPolicy",
      "DeleteModelQualityJobDefinition",
      "DeleteMonitoringSchedule",
      "DeleteNotebookInstance",
      "DeleteNotebookInstanceLifecycleConfig",
      "DeletePipeline",
      "DeleteProject",
      "DeleteRecord",
      "DeleteSpace",
      "DeleteStudioLifecycleConfig",
      "DeleteTrial",
      "DeleteTrialComponent",
      "DeleteUserProfile",
      "DeleteWorkforce",
      "DeleteWorkteam",
      "DeregisterDevices",
      "DisableSagemakerServicecatalogPortfolio",
      "DisassociateTrialComponent",
      "EnableSagemakerServicecatalogPortfolio",
      "ImportHubContent",
      "PutLineageGroupPolicy",
      "PutModelPackageGroupPolicy",
      "PutRecord",
      "RegisterDevices",
      "RetryPipelineExecution",
      "SendHeartbeat",
      "SendPipelineExecutionStepFailure",
      "SendPipelineExecutionStepSuccess",
      "SendSharedModelEvent",
      "StartEdgeDeploymentStage",
      "StartHumanLoop",
      "StartInferenceExperiment",
      "StartMonitoringSchedule",
      "StartNotebookInstance",
      "StartPipelineExecution",
      "StopAutoMLJob",
      "StopCompilationJob",
      "StopEdgeDeploymentStage",
      "StopEdgePackagingJob",
      "StopHumanLoop",
      "StopHyperParameterTuningJob",
      "StopInferenceExperiment",
      "StopInferenceRecommendationsJob",
      "StopLabelingJob",
      "StopMonitoringSchedule",
      "StopNotebookInstance",
      "StopPipelineExecution",
      "StopProcessingJob",
      "StopTrainingJob",
      "StopTransformJob",
      "UpdateAction",
      "UpdateAppImageConfig",
      "UpdateArtifact",
      "UpdateCodeRepository",
      "UpdateContext",
      "UpdateDeviceFleet",
      "UpdateDevices",
      "UpdateDomain",
      "UpdateEndpoint",
      "UpdateEndpointWeightsAndCapacities",
      "UpdateExperiment",
      "UpdateFeatureGroup",
      "UpdateFeatureMetadata",
      "UpdateHub",
      "UpdateImage",
      "UpdateImageVersion",
      "UpdateInferenceExperiment",
      "UpdateModelCard",
      "UpdateModelPackage",
      "UpdateMonitoringAlert",
      "UpdateMonitoringSchedule",
      "UpdateNotebookInstance",
      "UpdateNotebookInstanceLifecycleConfig",
      "UpdatePipeline",
      "UpdatePipelineExecution",
      "UpdateProject",
      "UpdateSharedModel",
      "UpdateSpace",
      "UpdateTrainingJob",
      "UpdateTrial",
      "UpdateTrialComponent",
      "UpdateUserProfile",
      "UpdateWorkforce",
      "UpdateWorkteam"
    ]
    permissions_management = []
    read = [
      "BatchDescribeModelPackage",
      "BatchGetMetrics",
      "BatchGetRecord",
      "DescribeAction",
      "DescribeAlgorithm",
      "DescribeApp",
      "DescribeAppImageConfig",
      "DescribeArtifact",
      "DescribeAutoMLJob",
      "DescribeAutoMLJobV2",
      "DescribeCodeRepository",
      "DescribeCompilationJob",
      "DescribeContext",
      "DescribeDataQualityJobDefinition",
      "DescribeDevice",
      "DescribeDeviceFleet",
      "DescribeDomain",
      "DescribeEdgeDeploymentPlan",
      "DescribeEdgePackagingJob",
      "DescribeEndpoint",
      "DescribeEndpointConfig",
      "DescribeExperiment",
      "DescribeFeatureGroup",
      "DescribeFeatureMetadata",
      "DescribeFlowDefinition",
      "DescribeHub",
      "DescribeHubContent",
      "DescribeHumanLoop",
      "DescribeHumanTaskUi",
      "DescribeHyperParameterTuningJob",
      "DescribeImage",
      "DescribeImageVersion",
      "DescribeInferenceExperiment",
      "DescribeInferenceRecommendationsJob",
      "DescribeLabelingJob",
      "DescribeLineageGroup",
      "DescribeModel",
      "DescribeModelBiasJobDefinition",
      "DescribeModelCard",
      "DescribeModelCardExportJob",
      "DescribeModelExplainabilityJobDefinition",
      "DescribeModelPackage",
      "DescribeModelPackageGroup",
      "DescribeModelQualityJobDefinition",
      "DescribeMonitoringSchedule",
      "DescribeNotebookInstance",
      "DescribeNotebookInstanceLifecycleConfig",
      "DescribePipeline",
      "DescribePipelineDefinitionForExecution",
      "DescribePipelineExecution",
      "DescribeProcessingJob",
      "DescribeProject",
      "DescribeSharedModel",
      "DescribeSpace",
      "DescribeStudioLifecycleConfig",
      "DescribeSubscribedWorkteam",
      "DescribeTrainingJob",
      "DescribeTransformJob",
      "DescribeTrial",
      "DescribeTrialComponent",
      "DescribeUserProfile",
      "DescribeWorkforce",
      "DescribeWorkteam",
      "GetDeployments",
      "GetDeviceFleetReport",
      "GetDeviceRegistration",
      "GetLineageGroupPolicy",
      "GetModelPackageGroupPolicy",
      "GetRecord",
      "GetSagemakerServicecatalogPortfolioStatus",
      "GetScalingPolicyConfigurationRecommendation",
      "GetSearchSuggestions",
      "InvokeEndpoint",
      "InvokeEndpointAsync",
      "RenderUiTemplate",
      "Search"
    ]
    list = [
      "ListActions",
      "ListAlgorithms",
      "ListAliases",
      "ListAppImageConfigs",
      "ListApps",
      "ListArtifacts",
      "ListAssociations",
      "ListAutoMLJobs",
      "ListCandidatesForAutoMLJob",
      "ListCodeRepositories",
      "ListCompilationJobs",
      "ListContexts",
      "ListDataQualityJobDefinitions",
      "ListDeviceFleets",
      "ListDevices",
      "ListDomains",
      "ListEdgeDeploymentPlans",
      "ListEdgePackagingJobs",
      "ListEndpointConfigs",
      "ListEndpoints",
      "ListExperiments",
      "ListFeatureGroups",
      "ListFlowDefinitions",
      "ListHubContentVersions",
      "ListHubContents",
      "ListHubs",
      "ListHumanLoops",
      "ListHumanTaskUis",
      "ListHyperParameterTuningJobs",
      "ListImageVersions",
      "ListImages",
      "ListInferenceExperiments",
      "ListInferenceRecommendationsJobSteps",
      "ListInferenceRecommendationsJobs",
      "ListLabelingJobs",
      "ListLabelingJobsForWorkteam",
      "ListLineageGroups",
      "ListModelBiasJobDefinitions",
      "ListModelCardExportJobs",
      "ListModelCardVersions",
      "ListModelCards",
      "ListModelExplainabilityJobDefinitions",
      "ListModelMetadata",
      "ListModelPackageGroups",
      "ListModelPackages",
      "ListModelQualityJobDefinitions",
      "ListModels",
      "ListMonitoringAlertHistory",
      "ListMonitoringAlerts",
      "ListMonitoringExecutions",
      "ListMonitoringSchedules",
      "ListNotebookInstanceLifecycleConfigs",
      "ListNotebookInstances",
      "ListPipelineExecutionSteps",
      "ListPipelineExecutions",
      "ListPipelineParametersForExecution",
      "ListPipelines",
      "ListProcessingJobs",
      "ListProjects",
      "ListResourceCatalogs",
      "ListSharedModelEvents",
      "ListSharedModelVersions",
      "ListSharedModels",
      "ListSpaces",
      "ListStageDevices",
      "ListStudioLifecycleConfigs",
      "ListSubscribedWorkteams",
      "ListTags",
      "ListTrainingJobs",
      "ListTrainingJobsForHyperParameterTuningJob",
      "ListTransformJobs",
      "ListTrialComponents",
      "ListTrials",
      "ListUserProfiles",
      "ListWorkforces",
      "ListWorkteams",
      "QueryLineage"
    ]
    tagging = [
      "AddTags",
      "DeleteTags"
    ]
  }
}
