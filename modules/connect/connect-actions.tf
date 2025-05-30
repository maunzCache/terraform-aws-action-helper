locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonconnect.html

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

  prefix = "connect"

  access_level = {
    write = [
      "ActivateEvaluationForm",
      "AdminGetEmergencyAccessToken",
      "AssociateAnalyticsDataSet",
      "AssociateApprovedOrigin",
      "AssociateBot",
      "AssociateCustomerProfilesDomain",
      "AssociateDefaultVocabulary",
      "AssociateFlow",
      "AssociateInstanceStorageConfig",
      "AssociateLambdaFunction",
      "AssociateLexBot",
      "AssociatePhoneNumberContactFlow",
      "AssociateQueueQuickConnects",
      "AssociateRoutingProfileQueues",
      "AssociateSecurityKey",
      "AssociateTrafficDistributionGroupUser",
      "AssociateUserProficiencies",
      "BatchAssociateAnalyticsDataSet",
      "BatchDisassociateAnalyticsDataSet",
      "BatchPutContact",
      "ClaimPhoneNumber",
      "CompleteAttachedFileUpload",
      "CreateAgentStatus",
      "CreateAuthenticationProfile",
      "CreateContact",
      "CreateContactFlow",
      "CreateContactFlowModule",
      "CreateContactFlowVersion",
      "CreateEmailAddress",
      "CreateEvaluationForm",
      "CreateHoursOfOperation",
      "CreateHoursOfOperationOverride",
      "CreateInstance",
      "CreateIntegrationAssociation",
      "CreateParticipant",
      "CreatePersistentContactAssociation",
      "CreatePredefinedAttribute",
      "CreatePrompt",
      "CreatePushNotificationRegistration",
      "CreateQueue",
      "CreateQuickConnect",
      "CreateRoutingProfile",
      "CreateRule",
      "CreateSecurityProfile",
      "CreateTaskTemplate",
      "CreateTrafficDistributionGroup",
      "CreateUseCase",
      "CreateUser",
      "CreateUserHierarchyGroup",
      "CreateView",
      "CreateViewVersion",
      "CreateVocabulary",
      "DeactivateEvaluationForm",
      "DeleteAttachedFile",
      "DeleteContactEvaluation",
      "DeleteContactFlow",
      "DeleteContactFlowModule",
      "DeleteContactFlowVersion",
      "DeleteEmailAddress",
      "DeleteEvaluationForm",
      "DeleteHoursOfOperation",
      "DeleteHoursOfOperationOverride",
      "DeleteInstance",
      "DeleteIntegrationAssociation",
      "DeletePredefinedAttribute",
      "DeletePrompt",
      "DeletePushNotificationRegistration",
      "DeleteQueue",
      "DeleteQuickConnect",
      "DeleteRoutingProfile",
      "DeleteRule",
      "DeleteSecurityProfile",
      "DeleteTaskTemplate",
      "DeleteTrafficDistributionGroup",
      "DeleteUseCase",
      "DeleteUser",
      "DeleteUserHierarchyGroup",
      "DeleteView",
      "DeleteViewVersion",
      "DeleteVocabulary",
      "DisassociateAnalyticsDataSet",
      "DisassociateApprovedOrigin",
      "DisassociateBot",
      "DisassociateCustomerProfilesDomain",
      "DisassociateFlow",
      "DisassociateInstanceStorageConfig",
      "DisassociateLambdaFunction",
      "DisassociateLexBot",
      "DisassociatePhoneNumberContactFlow",
      "DisassociateQueueQuickConnects",
      "DisassociateRoutingProfileQueues",
      "DisassociateSecurityKey",
      "DisassociateTrafficDistributionGroupUser",
      "DisassociateUserProficiencies",
      "DismissUserContact",
      "ImportPhoneNumber",
      "MonitorContact",
      "PauseContact",
      "PutUserStatus",
      "ReleasePhoneNumber",
      "ReplicateInstance",
      "ResumeContact",
      "ResumeContactRecording",
      "SendChatIntegrationEvent",
      "SendIntegrationEvent",
      "SendOutboundEmail",
      "StartAttachedFileUpload",
      "StartChatContact",
      "StartContactEvaluation",
      "StartContactRecording",
      "StartContactStreaming",
      "StartEmailContact",
      "StartForecastingPlanningSchedulingIntegration",
      "StartOutboundChatContact",
      "StartOutboundEmailContact",
      "StartOutboundVoiceContact",
      "StartScreenSharing",
      "StartTaskContact",
      "StartWebRTCContact",
      "StopContact",
      "StopContactRecording",
      "StopContactStreaming",
      "StopForecastingPlanningSchedulingIntegration",
      "SubmitContactEvaluation",
      "SuspendContactRecording",
      "TagContact",
      "TransferContact",
      "UntagContact",
      "UpdateAgentStatus",
      "UpdateAuthenticationProfile",
      "UpdateContact",
      "UpdateContactAttributes",
      "UpdateContactEvaluation",
      "UpdateContactFlowContent",
      "UpdateContactFlowMetadata",
      "UpdateContactFlowModuleContent",
      "UpdateContactFlowModuleMetadata",
      "UpdateContactFlowName",
      "UpdateContactRoutingData",
      "UpdateContactSchedule",
      "UpdateEmailAddressMetadata",
      "UpdateEvaluationForm",
      "UpdateHoursOfOperation",
      "UpdateHoursOfOperationOverride",
      "UpdateInstanceAttribute",
      "UpdateInstanceStorageConfig",
      "UpdateParticipantAuthentication",
      "UpdateParticipantRoleConfig",
      "UpdatePhoneNumber",
      "UpdatePhoneNumberMetadata",
      "UpdatePredefinedAttribute",
      "UpdatePrompt",
      "UpdateQueueHoursOfOperation",
      "UpdateQueueMaxContacts",
      "UpdateQueueName",
      "UpdateQueueOutboundCallerConfig",
      "UpdateQueueOutboundEmailConfig",
      "UpdateQueueStatus",
      "UpdateQuickConnectConfig",
      "UpdateQuickConnectName",
      "UpdateRoutingProfileAgentAvailabilityTimer",
      "UpdateRoutingProfileConcurrency",
      "UpdateRoutingProfileDefaultOutboundQueue",
      "UpdateRoutingProfileName",
      "UpdateRoutingProfileQueues",
      "UpdateRule",
      "UpdateSecurityProfile",
      "UpdateTaskTemplate",
      "UpdateTrafficDistribution",
      "UpdateUserHierarchy",
      "UpdateUserHierarchyGroupName",
      "UpdateUserHierarchyStructure",
      "UpdateUserIdentityInfo",
      "UpdateUserPhoneConfig",
      "UpdateUserProficiencies",
      "UpdateUserRoutingProfile",
      "UpdateUserSecurityProfiles",
      "UpdateViewContent",
      "UpdateViewMetadata"
    ]
    permissions_management = []
    read = [
      "BatchGetAttachedFileMetadata",
      "DescribeAgentStatus",
      "DescribeAuthenticationProfile",
      "DescribeContact",
      "DescribeContactEvaluation",
      "DescribeContactFlow",
      "DescribeContactFlowModule",
      "DescribeEmailAddress",
      "DescribeEvaluationForm",
      "DescribeForecastingPlanningSchedulingIntegration",
      "DescribeHoursOfOperation",
      "DescribeHoursOfOperationOverride",
      "DescribeInstance",
      "DescribeInstanceAttribute",
      "DescribeInstanceStorageConfig",
      "DescribePhoneNumber",
      "DescribePredefinedAttribute",
      "DescribePrompt",
      "DescribeQueue",
      "DescribeQuickConnect",
      "DescribeRoutingProfile",
      "DescribeRule",
      "DescribeSecurityProfile",
      "DescribeTrafficDistributionGroup",
      "DescribeUser",
      "DescribeUserHierarchyGroup",
      "DescribeUserHierarchyStructure",
      "DescribeView",
      "DescribeVocabulary",
      "GetAttachedFile",
      "GetContactAttributes",
      "GetCurrentMetricData",
      "GetCurrentUserData",
      "GetEffectiveHoursOfOperations",
      "GetFederationToken",
      "GetFlowAssociation",
      "GetMetricData",
      "GetMetricDataV2",
      "GetPromptFile",
      "GetTaskTemplate",
      "ListRealtimeContactAnalysisSegments",
      "ListTagsForResource",
      "SearchAgentStatuses",
      "SearchContactFlowModules",
      "SearchContactFlows",
      "SearchContacts",
      "SearchEmailAddresses",
      "SearchHoursOfOperationOverrides",
      "SearchHoursOfOperations",
      "SearchPredefinedAttributes",
      "SearchPrompts",
      "SearchQueues",
      "SearchQuickConnects",
      "SearchRoutingProfiles",
      "SearchSecurityProfiles",
      "SearchUserHierarchyGroups",
      "SearchUsers"
    ]
    list = [
      "BatchGetFlowAssociation",
      "GetTrafficDistribution",
      "ListAgentStatuses",
      "ListAnalyticsDataAssociations",
      "ListAnalyticsDataLakeDataSets",
      "ListApprovedOrigins",
      "ListAssociatedContacts",
      "ListAuthenticationProfiles",
      "ListBots",
      "ListContactEvaluations",
      "ListContactFlowModules",
      "ListContactFlowVersions",
      "ListContactFlows",
      "ListContactReferences",
      "ListDefaultVocabularies",
      "ListEvaluationFormVersions",
      "ListEvaluationForms",
      "ListFlowAssociations",
      "ListHoursOfOperationOverrides",
      "ListHoursOfOperations",
      "ListInstanceAttributes",
      "ListInstanceStorageConfigs",
      "ListInstances",
      "ListIntegrationAssociations",
      "ListLambdaFunctions",
      "ListLexBots",
      "ListPhoneNumbers",
      "ListPhoneNumbersV2",
      "ListPredefinedAttributes",
      "ListPrompts",
      "ListQueueQuickConnects",
      "ListQueues",
      "ListQuickConnects",
      "ListRealtimeContactAnalysisSegmentsV2",
      "ListRoutingProfileQueues",
      "ListRoutingProfiles",
      "ListRules",
      "ListSecurityKeys",
      "ListSecurityProfileApplications",
      "ListSecurityProfilePermissions",
      "ListSecurityProfiles",
      "ListTaskTemplates",
      "ListTrafficDistributionGroupUsers",
      "ListTrafficDistributionGroups",
      "ListUseCases",
      "ListUserHierarchyGroups",
      "ListUserProficiencies",
      "ListUsers",
      "ListViewVersions",
      "ListViews",
      "SearchAvailablePhoneNumbers",
      "SearchResourceTags",
      "SearchVocabularies"
    ]
    tagging = [
      "TagResource",
      "UntagResource"
    ]
  }
}
