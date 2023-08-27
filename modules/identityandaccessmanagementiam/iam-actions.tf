locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsidentityandaccessmanagementiam.html

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

  prefix = "iam"

  access_level = {
    write                  = [
    "AddClientIDToOpenIDConnectProvider",
    "AddRoleToInstanceProfile",
    "AddUserToGroup",
    "ChangePassword",
    "CreateAccessKey",
    "CreateAccountAlias",
    "CreateGroup",
    "CreateInstanceProfile",
    "CreateLoginProfile",
    "CreateOpenIDConnectProvider",
    "CreateRole",
    "CreateSAMLProvider",
    "CreateServiceLinkedRole",
    "CreateServiceSpecificCredential",
    "CreateUser",
    "CreateVirtualMFADevice",
    "DeactivateMFADevice",
    "DeleteAccessKey",
    "DeleteAccountAlias",
    "DeleteCloudFrontPublicKey",
    "DeleteGroup",
    "DeleteInstanceProfile",
    "DeleteLoginProfile",
    "DeleteOpenIDConnectProvider",
    "DeleteRole",
    "DeleteSAMLProvider",
    "DeleteSSHPublicKey",
    "DeleteServerCertificate",
    "DeleteServiceLinkedRole",
    "DeleteServiceSpecificCredential",
    "DeleteSigningCertificate",
    "DeleteUser",
    "DeleteVirtualMFADevice",
    "EnableMFADevice",
    "PassRole",
    "RemoveClientIDFromOpenIDConnectProvider",
    "RemoveRoleFromInstanceProfile",
    "RemoveUserFromGroup",
    "ResetServiceSpecificCredential",
    "ResyncMFADevice",
    "SetSTSRegionalEndpointStatus",
    "SetSecurityTokenServicePreferences",
    "UpdateAccessKey",
    "UpdateAccountEmailAddress",
    "UpdateAccountName",
    "UpdateAccountPasswordPolicy",
    "UpdateCloudFrontPublicKey",
    "UpdateGroup",
    "UpdateLoginProfile",
    "UpdateOpenIDConnectProviderThumbprint",
    "UpdateRole",
    "UpdateRoleDescription",
    "UpdateSAMLProvider",
    "UpdateSSHPublicKey",
    "UpdateServerCertificate",
    "UpdateServiceSpecificCredential",
    "UpdateSigningCertificate",
    "UpdateUser",
    "UploadCloudFrontPublicKey",
    "UploadSSHPublicKey",
    "UploadServerCertificate",
    "UploadSigningCertificate"
]
    permissions_management = [
    "AttachGroupPolicy",
    "AttachRolePolicy",
    "AttachUserPolicy",
    "CreatePolicy",
    "CreatePolicyVersion",
    "DeleteAccountPasswordPolicy",
    "DeleteGroupPolicy",
    "DeletePolicy",
    "DeletePolicyVersion",
    "DeleteRolePermissionsBoundary",
    "DeleteRolePolicy",
    "DeleteUserPermissionsBoundary",
    "DeleteUserPolicy",
    "DetachGroupPolicy",
    "DetachRolePolicy",
    "DetachUserPolicy",
    "PutGroupPolicy",
    "PutRolePermissionsBoundary",
    "PutRolePolicy",
    "PutUserPermissionsBoundary",
    "PutUserPolicy",
    "SetDefaultPolicyVersion",
    "UpdateAssumeRolePolicy"
]
    read                   = [
    "GenerateCredentialReport",
    "GenerateOrganizationsAccessReport",
    "GenerateServiceLastAccessedDetails",
    "GetAccessKeyLastUsed",
    "GetAccountAuthorizationDetails",
    "GetAccountEmailAddress",
    "GetAccountName",
    "GetAccountPasswordPolicy",
    "GetCloudFrontPublicKey",
    "GetContextKeysForCustomPolicy",
    "GetContextKeysForPrincipalPolicy",
    "GetCredentialReport",
    "GetGroup",
    "GetGroupPolicy",
    "GetInstanceProfile",
    "GetMFADevice",
    "GetOpenIDConnectProvider",
    "GetOrganizationsAccessReport",
    "GetPolicy",
    "GetPolicyVersion",
    "GetRole",
    "GetRolePolicy",
    "GetSAMLProvider",
    "GetSSHPublicKey",
    "GetServerCertificate",
    "GetServiceLastAccessedDetails",
    "GetServiceLastAccessedDetailsWithEntities",
    "GetServiceLinkedRoleDeletionStatus",
    "GetUser",
    "GetUserPolicy",
    "SimulateCustomPolicy",
    "SimulatePrincipalPolicy"
]
    list                   = [
    "GetAccountSummary",
    "GetLoginProfile",
    "ListAccessKeys",
    "ListAccountAliases",
    "ListAttachedGroupPolicies",
    "ListAttachedRolePolicies",
    "ListAttachedUserPolicies",
    "ListCloudFrontPublicKeys",
    "ListEntitiesForPolicy",
    "ListGroupPolicies",
    "ListGroups",
    "ListGroupsForUser",
    "ListInstanceProfileTags",
    "ListInstanceProfiles",
    "ListInstanceProfilesForRole",
    "ListMFADeviceTags",
    "ListMFADevices",
    "ListOpenIDConnectProviderTags",
    "ListOpenIDConnectProviders",
    "ListPolicies",
    "ListPoliciesGrantingServiceAccess",
    "ListPolicyTags",
    "ListPolicyVersions",
    "ListRolePolicies",
    "ListRoleTags",
    "ListRoles",
    "ListSAMLProviderTags",
    "ListSAMLProviders",
    "ListSSHPublicKeys",
    "ListSTSRegionalEndpointsStatus",
    "ListServerCertificateTags",
    "ListServerCertificates",
    "ListServiceSpecificCredentials",
    "ListSigningCertificates",
    "ListUserPolicies",
    "ListUserTags",
    "ListUsers",
    "ListVirtualMFADevices"
]
    tagging                = [
    "TagInstanceProfile",
    "TagMFADevice",
    "TagOpenIDConnectProvider",
    "TagPolicy",
    "TagRole",
    "TagSAMLProvider",
    "TagServerCertificate",
    "TagUser",
    "UntagInstanceProfile",
    "UntagMFADevice",
    "UntagOpenIDConnectProvider",
    "UntagPolicy",
    "UntagRole",
    "UntagSAMLProvider",
    "UntagServerCertificate",
    "UntagUser"
]
  }
}
