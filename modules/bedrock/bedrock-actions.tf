locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonbedrock.html

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

  prefix = "bedrock"

  access_level = {
    write = [
      "AssociateAgentCollaborator",
      "AssociateAgentKnowledgeBase",
      "AssociateThirdPartyKnowledgeBase",
      "BatchDeleteEvaluationJob",
      "CreateAgent",
      "CreateAgentActionGroup",
      "CreateAgentAlias",
      "CreateBlueprint",
      "CreateBlueprintVersion",
      "CreateDataAutomationProject",
      "CreateDataSource",
      "CreateEvaluationJob",
      "CreateFlow",
      "CreateFlowAlias",
      "CreateFlowVersion",
      "CreateFoundationModelAgreement",
      "CreateGuardrail",
      "CreateGuardrailVersion",
      "CreateInferenceProfile",
      "CreateInvocation",
      "CreateKnowledgeBase",
      "CreateMarketplaceModelEndpoint",
      "CreateModelCopyJob",
      "CreateModelCustomizationJob",
      "CreateModelEvaluationJob",
      "CreateModelImportJob",
      "CreateModelInvocationJob",
      "CreatePrompt",
      "CreatePromptRouter",
      "CreatePromptVersion",
      "CreateProvisionedModelThroughput",
      "CreateSession",
      "DeleteAgent",
      "DeleteAgentActionGroup",
      "DeleteAgentAlias",
      "DeleteAgentMemory",
      "DeleteAgentVersion",
      "DeleteBlueprint",
      "DeleteCustomModel",
      "DeleteDataAutomationProject",
      "DeleteDataSource",
      "DeleteFlow",
      "DeleteFlowAlias",
      "DeleteFlowVersion",
      "DeleteFoundationModelAgreement",
      "DeleteGuardrail",
      "DeleteImportedModel",
      "DeleteInferenceProfile",
      "DeleteKnowledgeBase",
      "DeleteKnowledgeBaseDocuments",
      "DeleteMarketplaceModelAgreement",
      "DeleteMarketplaceModelEndpoint",
      "DeleteModelInvocationLoggingConfiguration",
      "DeletePrompt",
      "DeletePromptRouter",
      "DeleteProvisionedModelThroughput",
      "DeleteResourcePolicy",
      "DeleteSession",
      "DeregisterMarketplaceModelEndpoint",
      "DisassociateAgentCollaborator",
      "DisassociateAgentKnowledgeBase",
      "EndSession",
      "IngestKnowledgeBaseDocuments",
      "InvokeBlueprintRecommendationAsync",
      "InvokeBuilder",
      "InvokeDataAutomationAsync",
      "PrepareAgent",
      "PrepareFlow",
      "PutFoundationModelEntitlement",
      "PutInvocationStep",
      "PutModelInvocationLoggingConfiguration",
      "PutResourcePolicy",
      "PutUseCaseForModelAccess",
      "RegisterMarketplaceModelEndpoint",
      "Rerank",
      "RetrieveAndGenerate",
      "StartFlowExecution",
      "StartIngestionJob",
      "StopEvaluationJob",
      "StopFlowExecution",
      "StopIngestionJob",
      "StopModelCustomizationJob",
      "StopModelInvocationJob",
      "UpdateAgent",
      "UpdateAgentActionGroup",
      "UpdateAgentAlias",
      "UpdateAgentCollaborator",
      "UpdateAgentKnowledgeBase",
      "UpdateBlueprint",
      "UpdateDataAutomationProject",
      "UpdateDataSource",
      "UpdateFlow",
      "UpdateFlowAlias",
      "UpdateGuardrail",
      "UpdateKnowledgeBase",
      "UpdateMarketplaceModelEndpoint",
      "UpdatePrompt",
      "UpdateProvisionedModelThroughput",
      "UpdateSession"
    ]
    permissions_management = [
      "AllowVendedLogDeliveryForResource"
    ]
    read = [
      "ApplyGuardrail",
      "DetectGeneratedContent",
      "GenerateQuery",
      "GetAgent",
      "GetAgentActionGroup",
      "GetAgentAlias",
      "GetAgentCollaborator",
      "GetAgentKnowledgeBase",
      "GetAgentMemory",
      "GetAgentVersion",
      "GetAsyncInvoke",
      "GetBlueprint",
      "GetBlueprintRecommendation",
      "GetCustomModel",
      "GetDataAutomationProject",
      "GetDataAutomationStatus",
      "GetDataSource",
      "GetEvaluationJob",
      "GetExecutionFlowSnapshot",
      "GetFlow",
      "GetFlowAlias",
      "GetFlowExecution",
      "GetFlowVersion",
      "GetFoundationModel",
      "GetFoundationModelAvailability",
      "GetGuardrail",
      "GetImportedModel",
      "GetInferenceProfile",
      "GetIngestionJob",
      "GetInvocationStep",
      "GetKnowledgeBase",
      "GetKnowledgeBaseDocuments",
      "GetMarketplaceModelEndpoint",
      "GetModelCopyJob",
      "GetModelCustomizationJob",
      "GetModelEvaluationJob",
      "GetModelImportJob",
      "GetModelInvocationJob",
      "GetModelInvocationLoggingConfiguration",
      "GetPrompt",
      "GetPromptRouter",
      "GetProvisionedModelThroughput",
      "GetResourcePolicy",
      "GetSession",
      "GetUseCaseForModelAccess",
      "InvokeAgent",
      "InvokeFlow",
      "InvokeInlineAgent",
      "InvokeModel",
      "InvokeModelWithResponseStream",
      "ListMarketplaceModelEndpoints",
      "ListTagsForResource",
      "OptimizePrompt",
      "RenderPrompt",
      "Retrieve",
      "ValidateFlowDefinition"
    ]
    list = [
      "ListAgentActionGroups",
      "ListAgentAliases",
      "ListAgentCollaborators",
      "ListAgentKnowledgeBases",
      "ListAgentVersions",
      "ListAgents",
      "ListAsyncInvokes",
      "ListBlueprints",
      "ListCustomModels",
      "ListDataAutomationProjects",
      "ListDataSources",
      "ListEvaluationJobs",
      "ListFlowAliases",
      "ListFlowExecutionEvents",
      "ListFlowExecutions",
      "ListFlowVersions",
      "ListFlows",
      "ListFoundationModelAgreementOffers",
      "ListFoundationModels",
      "ListGuardrails",
      "ListImportedModels",
      "ListInferenceProfiles",
      "ListIngestionJobs",
      "ListInvocationSteps",
      "ListInvocations",
      "ListKnowledgeBaseDocuments",
      "ListKnowledgeBases",
      "ListModelCopyJobs",
      "ListModelCustomizationJobs",
      "ListModelEvaluationJobs",
      "ListModelImportJobs",
      "ListModelInvocationJobs",
      "ListPromptRouters",
      "ListPrompts",
      "ListProvisionedModelThroughputs",
      "ListSessions"
    ]
    tagging = [
      "TagResource",
      "UntagResource"
    ]
  }
}
