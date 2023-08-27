locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3.html

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

  prefix = "s3"

  access_level = {
    write                  = [
    "AbortMultipartUpload",
    "CreateAccessPoint",
    "CreateAccessPointForObjectLambda",
    "CreateBucket",
    "CreateJob",
    "CreateMultiRegionAccessPoint",
    "DeleteAccessPoint",
    "DeleteAccessPointForObjectLambda",
    "DeleteBucket",
    "DeleteBucketWebsite",
    "DeleteMultiRegionAccessPoint",
    "DeleteObject",
    "DeleteObjectVersion",
    "DeleteStorageLensConfiguration",
    "InitiateReplication",
    "PutAccelerateConfiguration",
    "PutAccessPointConfigurationForObjectLambda",
    "PutAnalyticsConfiguration",
    "PutBucketCORS",
    "PutBucketLogging",
    "PutBucketNotification",
    "PutBucketObjectLockConfiguration",
    "PutBucketOwnershipControls",
    "PutBucketRequestPayment",
    "PutBucketVersioning",
    "PutBucketWebsite",
    "PutEncryptionConfiguration",
    "PutIntelligentTieringConfiguration",
    "PutInventoryConfiguration",
    "PutLifecycleConfiguration",
    "PutMetricsConfiguration",
    "PutObject",
    "PutObjectLegalHold",
    "PutObjectRetention",
    "PutReplicationConfiguration",
    "PutStorageLensConfiguration",
    "ReplicateDelete",
    "ReplicateObject",
    "RestoreObject",
    "SubmitMultiRegionAccessPointRoutes",
    "UpdateJobPriority",
    "UpdateJobStatus"
]
    permissions_management = [
    "BypassGovernanceRetention",
    "DeleteAccessPointPolicy",
    "DeleteAccessPointPolicyForObjectLambda",
    "DeleteBucketPolicy",
    "ObjectOwnerOverrideToBucketOwner",
    "PutAccessPointPolicy",
    "PutAccessPointPolicyForObjectLambda",
    "PutAccessPointPublicAccessBlock",
    "PutAccountPublicAccessBlock",
    "PutBucketAcl",
    "PutBucketPolicy",
    "PutBucketPublicAccessBlock",
    "PutMultiRegionAccessPointPolicy",
    "PutObjectAcl",
    "PutObjectVersionAcl"
]
    read                   = [
    "DescribeJob",
    "DescribeMultiRegionAccessPointOperation",
    "GetAccelerateConfiguration",
    "GetAccessPoint",
    "GetAccessPointConfigurationForObjectLambda",
    "GetAccessPointForObjectLambda",
    "GetAccessPointPolicy",
    "GetAccessPointPolicyForObjectLambda",
    "GetAccessPointPolicyStatus",
    "GetAccessPointPolicyStatusForObjectLambda",
    "GetAccountPublicAccessBlock",
    "GetAnalyticsConfiguration",
    "GetBucketAcl",
    "GetBucketCORS",
    "GetBucketLocation",
    "GetBucketLogging",
    "GetBucketNotification",
    "GetBucketObjectLockConfiguration",
    "GetBucketOwnershipControls",
    "GetBucketPolicy",
    "GetBucketPolicyStatus",
    "GetBucketPublicAccessBlock",
    "GetBucketRequestPayment",
    "GetBucketTagging",
    "GetBucketVersioning",
    "GetBucketWebsite",
    "GetEncryptionConfiguration",
    "GetIntelligentTieringConfiguration",
    "GetInventoryConfiguration",
    "GetJobTagging",
    "GetLifecycleConfiguration",
    "GetMetricsConfiguration",
    "GetMultiRegionAccessPoint",
    "GetMultiRegionAccessPointPolicy",
    "GetMultiRegionAccessPointPolicyStatus",
    "GetMultiRegionAccessPointRoutes",
    "GetObject",
    "GetObjectAcl",
    "GetObjectAttributes",
    "GetObjectLegalHold",
    "GetObjectRetention",
    "GetObjectTagging",
    "GetObjectTorrent",
    "GetObjectVersion",
    "GetObjectVersionAcl",
    "GetObjectVersionAttributes",
    "GetObjectVersionForReplication",
    "GetObjectVersionTagging",
    "GetObjectVersionTorrent",
    "GetReplicationConfiguration",
    "GetStorageLensConfiguration",
    "GetStorageLensConfigurationTagging",
    "GetStorageLensDashboard"
]
    list                   = [
    "ListAccessPoints",
    "ListAccessPointsForObjectLambda",
    "ListAllMyBuckets",
    "ListBucket",
    "ListBucketMultipartUploads",
    "ListBucketVersions",
    "ListJobs",
    "ListMultiRegionAccessPoints",
    "ListMultipartUploadParts",
    "ListStorageLensConfigurations"
]
    tagging                = [
    "DeleteJobTagging",
    "DeleteObjectTagging",
    "DeleteObjectVersionTagging",
    "DeleteStorageLensConfigurationTagging",
    "PutBucketTagging",
    "PutJobTagging",
    "PutObjectTagging",
    "PutObjectVersionTagging",
    "PutStorageLensConfigurationTagging",
    "ReplicateTags"
]
  }
}
