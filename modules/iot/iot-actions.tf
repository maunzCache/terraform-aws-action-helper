locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsiot.html

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

  prefix = "iot"

  access_level = {
    write = [
      "AcceptCertificateTransfer",
      "AddThingToBillingGroup",
      "AddThingToThingGroup",
      "AssociateTargetsWithJob",
      "AttachSecurityProfile",
      "AttachThingPrincipal",
      "CancelAuditMitigationActionsTask",
      "CancelAuditTask",
      "CancelCertificateTransfer",
      "CancelDetectMitigationActionsTask",
      "CancelJob",
      "CancelJobExecution",
      "ClearDefaultAuthorizer",
      "CloseTunnel",
      "ConfirmTopicRuleDestination",
      "Connect",
      "CreateAuditSuppression",
      "CreateAuthorizer",
      "CreateBillingGroup",
      "CreateCertificateFromCsr",
      "CreateCustomMetric",
      "CreateDimension",
      "CreateDomainConfiguration",
      "CreateDynamicThingGroup",
      "CreateFleetMetric",
      "CreateJob",
      "CreateJobTemplate",
      "CreateKeysAndCertificate",
      "CreateMitigationAction",
      "CreateOTAUpdate",
      "CreatePackage",
      "CreatePackageVersion",
      "CreatePolicy",
      "CreatePolicyVersion",
      "CreateProvisioningClaim",
      "CreateProvisioningTemplate",
      "CreateProvisioningTemplateVersion",
      "CreateRoleAlias",
      "CreateScheduledAudit",
      "CreateSecurityProfile",
      "CreateStream",
      "CreateThing",
      "CreateThingGroup",
      "CreateThingType",
      "CreateTopicRule",
      "CreateTopicRuleDestination",
      "DeleteAccountAuditConfiguration",
      "DeleteAuditSuppression",
      "DeleteAuthorizer",
      "DeleteBillingGroup",
      "DeleteCACertificate",
      "DeleteCertificate",
      "DeleteCustomMetric",
      "DeleteDimension",
      "DeleteDomainConfiguration",
      "DeleteDynamicThingGroup",
      "DeleteFleetMetric",
      "DeleteJob",
      "DeleteJobExecution",
      "DeleteJobTemplate",
      "DeleteMitigationAction",
      "DeleteOTAUpdate",
      "DeletePackage",
      "DeletePackageVersion",
      "DeletePolicy",
      "DeletePolicyVersion",
      "DeleteProvisioningTemplate",
      "DeleteProvisioningTemplateVersion",
      "DeleteRegistrationCode",
      "DeleteRoleAlias",
      "DeleteScheduledAudit",
      "DeleteSecurityProfile",
      "DeleteStream",
      "DeleteThing",
      "DeleteThingGroup",
      "DeleteThingShadow",
      "DeleteThingType",
      "DeleteTopicRule",
      "DeleteTopicRuleDestination",
      "DeleteV2LoggingLevel",
      "DeprecateThingType",
      "DetachSecurityProfile",
      "DetachThingPrincipal",
      "DisableTopicRule",
      "EnableTopicRule",
      "OpenTunnel",
      "Publish",
      "PutVerificationStateOnViolation",
      "Receive",
      "RegisterCACertificate",
      "RegisterCertificate",
      "RegisterCertificateWithoutCA",
      "RegisterThing",
      "RejectCertificateTransfer",
      "RemoveThingFromBillingGroup",
      "RemoveThingFromThingGroup",
      "ReplaceTopicRule",
      "RetainPublish",
      "RotateTunnelAccessToken",
      "SetLoggingOptions",
      "SetV2LoggingLevel",
      "SetV2LoggingOptions",
      "StartAuditMitigationActionsTask",
      "StartDetectMitigationActionsTask",
      "StartOnDemandAuditTask",
      "StartThingRegistrationTask",
      "StopThingRegistrationTask",
      "Subscribe",
      "TransferCertificate",
      "UpdateAccountAuditConfiguration",
      "UpdateAuditSuppression",
      "UpdateAuthorizer",
      "UpdateBillingGroup",
      "UpdateCACertificate",
      "UpdateCertificate",
      "UpdateCustomMetric",
      "UpdateDimension",
      "UpdateDomainConfiguration",
      "UpdateDynamicThingGroup",
      "UpdateEventConfigurations",
      "UpdateFleetMetric",
      "UpdateIndexingConfiguration",
      "UpdateJob",
      "UpdateMitigationAction",
      "UpdatePackage",
      "UpdatePackageConfiguration",
      "UpdatePackageVersion",
      "UpdateProvisioningTemplate",
      "UpdateRoleAlias",
      "UpdateScheduledAudit",
      "UpdateSecurityProfile",
      "UpdateStream",
      "UpdateThing",
      "UpdateThingGroup",
      "UpdateThingGroupsForThing",
      "UpdateThingShadow",
      "UpdateTopicRuleDestination"
    ]
    permissions_management = [
      "AttachPolicy",
      "AttachPrincipalPolicy",
      "DetachPolicy",
      "DetachPrincipalPolicy",
      "SetDefaultAuthorizer",
      "SetDefaultPolicyVersion"
    ]
    read = [
      "DescribeAccountAuditConfiguration",
      "DescribeAuditFinding",
      "DescribeAuditMitigationActionsTask",
      "DescribeAuditSuppression",
      "DescribeAuditTask",
      "DescribeAuthorizer",
      "DescribeBillingGroup",
      "DescribeCACertificate",
      "DescribeCertificate",
      "DescribeCustomMetric",
      "DescribeDefaultAuthorizer",
      "DescribeDetectMitigationActionsTask",
      "DescribeDimension",
      "DescribeDomainConfiguration",
      "DescribeEndpoint",
      "DescribeEventConfigurations",
      "DescribeFleetMetric",
      "DescribeIndex",
      "DescribeJob",
      "DescribeJobExecution",
      "DescribeJobTemplate",
      "DescribeManagedJobTemplate",
      "DescribeMitigationAction",
      "DescribeProvisioningTemplate",
      "DescribeProvisioningTemplateVersion",
      "DescribeRoleAlias",
      "DescribeScheduledAudit",
      "DescribeSecurityProfile",
      "DescribeStream",
      "DescribeThing",
      "DescribeThingGroup",
      "DescribeThingRegistrationTask",
      "DescribeThingType",
      "DescribeTunnel",
      "GetBucketsAggregation",
      "GetCardinality",
      "GetEffectivePolicies",
      "GetIndexingConfiguration",
      "GetJobDocument",
      "GetLoggingOptions",
      "GetOTAUpdate",
      "GetPackage",
      "GetPackageConfiguration",
      "GetPackageVersion",
      "GetPercentiles",
      "GetPolicy",
      "GetPolicyVersion",
      "GetRegistrationCode",
      "GetRetainedMessage",
      "GetStatistics",
      "GetThingShadow",
      "GetTopicRule",
      "GetTopicRuleDestination",
      "GetV2LoggingOptions",
      "ListTagsForResource",
      "SearchIndex",
      "TestAuthorization",
      "TestInvokeAuthorizer",
      "ValidateSecurityProfileBehaviors"
    ]
    list = [
      "GetBehaviorModelTrainingSummaries",
      "ListActiveViolations",
      "ListAttachedPolicies",
      "ListAuditFindings",
      "ListAuditMitigationActionsExecutions",
      "ListAuditMitigationActionsTasks",
      "ListAuditSuppressions",
      "ListAuditTasks",
      "ListAuthorizers",
      "ListBillingGroups",
      "ListCACertificates",
      "ListCertificates",
      "ListCertificatesByCA",
      "ListCustomMetrics",
      "ListDetectMitigationActionsExecutions",
      "ListDetectMitigationActionsTasks",
      "ListDimensions",
      "ListDomainConfigurations",
      "ListFleetMetrics",
      "ListIndices",
      "ListJobExecutionsForJob",
      "ListJobExecutionsForThing",
      "ListJobTemplates",
      "ListJobs",
      "ListManagedJobTemplates",
      "ListMetricValues",
      "ListMitigationActions",
      "ListNamedShadowsForThing",
      "ListOTAUpdates",
      "ListOutgoingCertificates",
      "ListPackageVersions",
      "ListPackages",
      "ListPolicies",
      "ListPolicyPrincipals",
      "ListPolicyVersions",
      "ListPrincipalPolicies",
      "ListPrincipalThings",
      "ListProvisioningTemplateVersions",
      "ListProvisioningTemplates",
      "ListRelatedResourcesForAuditFinding",
      "ListRetainedMessages",
      "ListRoleAliases",
      "ListScheduledAudits",
      "ListSecurityProfiles",
      "ListSecurityProfilesForTarget",
      "ListStreams",
      "ListTargetsForPolicy",
      "ListTargetsForSecurityProfile",
      "ListThingGroups",
      "ListThingGroupsForThing",
      "ListThingPrincipals",
      "ListThingRegistrationTaskReports",
      "ListThingRegistrationTasks",
      "ListThingTypes",
      "ListThings",
      "ListThingsInBillingGroup",
      "ListThingsInThingGroup",
      "ListTopicRuleDestinations",
      "ListTopicRules",
      "ListTunnels",
      "ListV2LoggingLevels",
      "ListViolationEvents"
    ]
    tagging = [
      "TagResource",
      "UntagResource"
    ]
  }
}
