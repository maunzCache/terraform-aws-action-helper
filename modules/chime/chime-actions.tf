locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonchime.html

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

  prefix = "chime"

  access_level = {
    write                  = [
    "AcceptDelegate",
    "ActivateUsers",
    "AddDomain",
    "AddOrUpdateGroups",
    "AssociateChannelFlow",
    "AssociatePhoneNumberWithUser",
    "AssociatePhoneNumbersWithVoiceConnector",
    "AssociatePhoneNumbersWithVoiceConnectorGroup",
    "AssociateSigninDelegateGroupsWithAccount",
    "AuthorizeDirectory",
    "BatchCreateAttendee",
    "BatchCreateChannelMembership",
    "BatchCreateRoomMembership",
    "BatchDeletePhoneNumber",
    "BatchSuspendUser",
    "BatchUnsuspendUser",
    "BatchUpdateAttendeeCapabilitiesExcept",
    "BatchUpdatePhoneNumber",
    "BatchUpdateUser",
    "ChannelFlowCallback",
    "Connect",
    "ConnectDirectory",
    "CreateAccount",
    "CreateApiKey",
    "CreateAppInstance",
    "CreateAppInstanceAdmin",
    "CreateAppInstanceBot",
    "CreateAppInstanceUser",
    "CreateAttendee",
    "CreateBot",
    "CreateCDRBucket",
    "CreateChannel",
    "CreateChannelBan",
    "CreateChannelFlow",
    "CreateChannelMembership",
    "CreateChannelModerator",
    "CreateMediaCapturePipeline",
    "CreateMediaConcatenationPipeline",
    "CreateMediaInsightsPipeline",
    "CreateMediaInsightsPipelineConfiguration",
    "CreateMediaLiveConnectorPipeline",
    "CreateMeeting",
    "CreateMeetingDialOut",
    "CreateMeetingWithAttendees",
    "CreatePhoneNumberOrder",
    "CreateProxySession",
    "CreateRoom",
    "CreateRoomMembership",
    "CreateSipMediaApplication",
    "CreateSipMediaApplicationCall",
    "CreateSipRule",
    "CreateUser",
    "CreateVoiceConnector",
    "CreateVoiceConnectorGroup",
    "CreateVoiceProfile",
    "CreateVoiceProfileDomain",
    "DeleteAccount",
    "DeleteAccountOpenIdConfig",
    "DeleteApiKey",
    "DeleteAppInstance",
    "DeleteAppInstanceAdmin",
    "DeleteAppInstanceBot",
    "DeleteAppInstanceStreamingConfigurations",
    "DeleteAppInstanceUser",
    "DeleteAttendee",
    "DeleteCDRBucket",
    "DeleteChannel",
    "DeleteChannelBan",
    "DeleteChannelFlow",
    "DeleteChannelMembership",
    "DeleteChannelMessage",
    "DeleteChannelModerator",
    "DeleteDelegate",
    "DeleteDomain",
    "DeleteEventsConfiguration",
    "DeleteGroups",
    "DeleteMediaCapturePipeline",
    "DeleteMediaInsightsPipelineConfiguration",
    "DeleteMediaPipeline",
    "DeleteMeeting",
    "DeleteMessagingStreamingConfigurations",
    "DeletePhoneNumber",
    "DeleteProxySession",
    "DeleteRoom",
    "DeleteRoomMembership",
    "DeleteSipMediaApplication",
    "DeleteSipRule",
    "DeleteVoiceConnector",
    "DeleteVoiceConnectorEmergencyCallingConfiguration",
    "DeleteVoiceConnectorGroup",
    "DeleteVoiceConnectorOrigination",
    "DeleteVoiceConnectorProxy",
    "DeleteVoiceConnectorStreamingConfiguration",
    "DeleteVoiceConnectorTermination",
    "DeleteVoiceConnectorTerminationCredentials",
    "DeleteVoiceProfile",
    "DeleteVoiceProfileDomain",
    "DeregisterAppInstanceUserEndpoint",
    "DisassociateChannelFlow",
    "DisassociatePhoneNumberFromUser",
    "DisassociatePhoneNumbersFromVoiceConnector",
    "DisassociatePhoneNumbersFromVoiceConnectorGroup",
    "DisassociateSigninDelegateGroupsFromAccount",
    "DisconnectDirectory",
    "InviteDelegate",
    "InviteUsers",
    "InviteUsersFromProvider",
    "LogoutUser",
    "PutAppInstanceRetentionSettings",
    "PutAppInstanceStreamingConfigurations",
    "PutAppInstanceUserExpirationSettings",
    "PutChannelExpirationSettings",
    "PutChannelMembershipPreferences",
    "PutEventsConfiguration",
    "PutMessagingStreamingConfigurations",
    "PutRetentionSettings",
    "PutSipMediaApplicationAlexaSkillConfiguration",
    "PutSipMediaApplicationLoggingConfiguration",
    "PutVoiceConnectorEmergencyCallingConfiguration",
    "PutVoiceConnectorLoggingConfiguration",
    "PutVoiceConnectorOrigination",
    "PutVoiceConnectorProxy",
    "PutVoiceConnectorStreamingConfiguration",
    "PutVoiceConnectorTermination",
    "PutVoiceConnectorTerminationCredentials",
    "RedactChannelMessage",
    "RedactConversationMessage",
    "RedactRoomMessage",
    "RegenerateSecurityToken",
    "RegisterAppInstanceUserEndpoint",
    "RenameAccount",
    "RenewDelegate",
    "ResetAccountResource",
    "ResetPersonalPIN",
    "RestorePhoneNumber",
    "SendChannelMessage",
    "StartDataExport",
    "StartMeetingTranscription",
    "StartSpeakerSearchTask",
    "StartVoiceToneAnalysisTask",
    "StopMeetingTranscription",
    "StopSpeakerSearchTask",
    "StopVoiceToneAnalysisTask",
    "SubmitSupportRequest",
    "SuspendUsers",
    "UnauthorizeDirectory",
    "UpdateAccount",
    "UpdateAccountOpenIdConfig",
    "UpdateAccountResource",
    "UpdateAccountSettings",
    "UpdateAppInstance",
    "UpdateAppInstanceBot",
    "UpdateAppInstanceUser",
    "UpdateAppInstanceUserEndpoint",
    "UpdateAttendeeCapabilities",
    "UpdateBot",
    "UpdateCDRSettings",
    "UpdateChannel",
    "UpdateChannelFlow",
    "UpdateChannelMessage",
    "UpdateChannelReadMarker",
    "UpdateGlobalSettings",
    "UpdateMediaInsightsPipelineConfiguration",
    "UpdateMediaInsightsPipelineStatus",
    "UpdatePhoneNumber",
    "UpdatePhoneNumberSettings",
    "UpdateProxySession",
    "UpdateRoom",
    "UpdateRoomMembership",
    "UpdateSipMediaApplication",
    "UpdateSipMediaApplicationCall",
    "UpdateSipRule",
    "UpdateSupportedLicenses",
    "UpdateUser",
    "UpdateUserLicenses",
    "UpdateUserSettings",
    "UpdateVoiceConnector",
    "UpdateVoiceConnectorGroup",
    "UpdateVoiceProfile",
    "UpdateVoiceProfileDomain",
    "ValidateE911Address"
]
    permissions_management = []
    read                   = [
    "DescribeAppInstance",
    "DescribeAppInstanceAdmin",
    "DescribeAppInstanceBot",
    "DescribeAppInstanceUser",
    "DescribeAppInstanceUserEndpoint",
    "DescribeChannel",
    "DescribeChannelBan",
    "DescribeChannelFlow",
    "DescribeChannelMembership",
    "DescribeChannelMembershipForAppInstanceUser",
    "DescribeChannelModeratedByAppInstanceUser",
    "DescribeChannelModerator",
    "GetAccount",
    "GetAccountResource",
    "GetAccountSettings",
    "GetAccountWithOpenIdConfig",
    "GetAppInstanceRetentionSettings",
    "GetAppInstanceStreamingConfigurations",
    "GetAttendee",
    "GetBot",
    "GetCDRBucket",
    "GetChannelMembershipPreferences",
    "GetChannelMessage",
    "GetChannelMessageStatus",
    "GetDomain",
    "GetEventsConfiguration",
    "GetGlobalSettings",
    "GetMediaCapturePipeline",
    "GetMediaInsightsPipelineConfiguration",
    "GetMediaPipeline",
    "GetMeeting",
    "GetMeetingDetail",
    "GetMessagingSessionEndpoint",
    "GetMessagingStreamingConfigurations",
    "GetPhoneNumber",
    "GetPhoneNumberOrder",
    "GetPhoneNumberSettings",
    "GetProxySession",
    "GetRetentionSettings",
    "GetRoom",
    "GetSipMediaApplication",
    "GetSipMediaApplicationAlexaSkillConfiguration",
    "GetSipMediaApplicationLoggingConfiguration",
    "GetSipRule",
    "GetSpeakerSearchTask",
    "GetTelephonyLimits",
    "GetUser",
    "GetUserActivityReportData",
    "GetUserByEmail",
    "GetUserSettings",
    "GetVoiceConnector",
    "GetVoiceConnectorEmergencyCallingConfiguration",
    "GetVoiceConnectorGroup",
    "GetVoiceConnectorLoggingConfiguration",
    "GetVoiceConnectorOrigination",
    "GetVoiceConnectorProxy",
    "GetVoiceConnectorStreamingConfiguration",
    "GetVoiceConnectorTermination",
    "GetVoiceConnectorTerminationHealth",
    "GetVoiceProfile",
    "GetVoiceProfileDomain",
    "GetVoiceToneAnalysisTask",
    "ListChannelMessages",
    "ListTagsForResource",
    "RetrieveDataExports",
    "SearchAvailablePhoneNumbers",
    "ValidateAccountResource"
]
    list                   = [
    "ListAccountUsageReportData",
    "ListAccounts",
    "ListApiKeys",
    "ListAppInstanceAdmins",
    "ListAppInstanceBots",
    "ListAppInstanceUserEndpoints",
    "ListAppInstanceUsers",
    "ListAppInstances",
    "ListAttendeeTags",
    "ListAttendees",
    "ListAvailableVoiceConnectorRegions",
    "ListBots",
    "ListCDRBucket",
    "ListCallingRegions",
    "ListChannelBans",
    "ListChannelFlows",
    "ListChannelMemberships",
    "ListChannelMembershipsForAppInstanceUser",
    "ListChannelModerators",
    "ListChannels",
    "ListChannelsAssociatedWithChannelFlow",
    "ListChannelsModeratedByAppInstanceUser",
    "ListDelegates",
    "ListDirectories",
    "ListDomains",
    "ListGroups",
    "ListMediaCapturePipelines",
    "ListMediaInsightsPipelineConfigurations",
    "ListMediaPipelines",
    "ListMeetingEvents",
    "ListMeetingTags",
    "ListMeetings",
    "ListMeetingsReportData",
    "ListPhoneNumberOrders",
    "ListPhoneNumbers",
    "ListProxySessions",
    "ListRoomMemberships",
    "ListRooms",
    "ListSipMediaApplications",
    "ListSipRules",
    "ListSubChannels",
    "ListSupportedPhoneNumberCountries",
    "ListUsers",
    "ListVoiceConnectorGroups",
    "ListVoiceConnectorTerminationCredentials",
    "ListVoiceConnectors",
    "ListVoiceProfileDomains",
    "ListVoiceProfiles",
    "SearchChannels"
]
    tagging                = [
    "TagAttendee",
    "TagMeeting",
    "TagResource",
    "UntagAttendee",
    "UntagMeeting",
    "UntagResource"
]
  }
}
