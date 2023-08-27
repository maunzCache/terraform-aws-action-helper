locals {
  # Reference: https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html

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

  prefix = "ec2"

  access_level = {
    write                  = [
    "AcceptAddressTransfer",
    "AcceptReservedInstancesExchangeQuote",
    "AcceptTransitGatewayMulticastDomainAssociations",
    "AcceptTransitGatewayPeeringAttachment",
    "AcceptTransitGatewayVpcAttachment",
    "AcceptVpcEndpointConnections",
    "AcceptVpcPeeringConnection",
    "AdvertiseByoipCidr",
    "AllocateAddress",
    "AllocateHosts",
    "AllocateIpamPoolCidr",
    "ApplySecurityGroupsToClientVpnTargetNetwork",
    "AssignIpv6Addresses",
    "AssignPrivateIpAddresses",
    "AssignPrivateNatGatewayAddress",
    "AssociateAddress",
    "AssociateClientVpnTargetNetwork",
    "AssociateDhcpOptions",
    "AssociateEnclaveCertificateIamRole",
    "AssociateIamInstanceProfile",
    "AssociateInstanceEventWindow",
    "AssociateIpamResourceDiscovery",
    "AssociateNatGatewayAddress",
    "AssociateRouteTable",
    "AssociateSubnetCidrBlock",
    "AssociateTransitGatewayMulticastDomain",
    "AssociateTransitGatewayPolicyTable",
    "AssociateTransitGatewayRouteTable",
    "AssociateTrunkInterface",
    "AssociateVerifiedAccessInstanceWebAcl",
    "AssociateVpcCidrBlock",
    "AttachClassicLinkVpc",
    "AttachInternetGateway",
    "AttachNetworkInterface",
    "AttachVerifiedAccessTrustProvider",
    "AttachVolume",
    "AttachVpnGateway",
    "AuthorizeClientVpnIngress",
    "AuthorizeSecurityGroupEgress",
    "AuthorizeSecurityGroupIngress",
    "BundleInstance",
    "CancelBundleTask",
    "CancelCapacityReservation",
    "CancelCapacityReservationFleets",
    "CancelConversionTask",
    "CancelExportTask",
    "CancelImageLaunchPermission",
    "CancelImportTask",
    "CancelReservedInstancesListing",
    "CancelSpotFleetRequests",
    "CancelSpotInstanceRequests",
    "ConfirmProductInstance",
    "CopyFpgaImage",
    "CopyImage",
    "CopySnapshot",
    "CreateCapacityReservation",
    "CreateCapacityReservationFleet",
    "CreateCarrierGateway",
    "CreateClientVpnEndpoint",
    "CreateClientVpnRoute",
    "CreateCoipCidr",
    "CreateCoipPool",
    "CreateCoipPoolPermission",
    "CreateCustomerGateway",
    "CreateDefaultSubnet",
    "CreateDefaultVpc",
    "CreateDhcpOptions",
    "CreateEgressOnlyInternetGateway",
    "CreateFleet",
    "CreateFlowLogs",
    "CreateFpgaImage",
    "CreateImage",
    "CreateInstanceConnectEndpoint",
    "CreateInstanceEventWindow",
    "CreateInstanceExportTask",
    "CreateInternetGateway",
    "CreateIpam",
    "CreateIpamPool",
    "CreateIpamResourceDiscovery",
    "CreateIpamScope",
    "CreateKeyPair",
    "CreateLaunchTemplate",
    "CreateLaunchTemplateVersion",
    "CreateLocalGatewayRoute",
    "CreateLocalGatewayRouteTable",
    "CreateLocalGatewayRouteTablePermission",
    "CreateLocalGatewayRouteTableVirtualInterfaceGroupAssociation",
    "CreateLocalGatewayRouteTableVpcAssociation",
    "CreateManagedPrefixList",
    "CreateNatGateway",
    "CreateNetworkAcl",
    "CreateNetworkAclEntry",
    "CreateNetworkInsightsAccessScope",
    "CreateNetworkInsightsPath",
    "CreateNetworkInterface",
    "CreatePlacementGroup",
    "CreatePublicIpv4Pool",
    "CreateReplaceRootVolumeTask",
    "CreateReservedInstancesListing",
    "CreateRestoreImageTask",
    "CreateRoute",
    "CreateRouteTable",
    "CreateSecurityGroup",
    "CreateSnapshot",
    "CreateSnapshots",
    "CreateSpotDatafeedSubscription",
    "CreateStoreImageTask",
    "CreateSubnet",
    "CreateSubnetCidrReservation",
    "CreateTrafficMirrorFilter",
    "CreateTrafficMirrorFilterRule",
    "CreateTrafficMirrorSession",
    "CreateTrafficMirrorTarget",
    "CreateTransitGateway",
    "CreateTransitGatewayConnect",
    "CreateTransitGatewayConnectPeer",
    "CreateTransitGatewayMulticastDomain",
    "CreateTransitGatewayPeeringAttachment",
    "CreateTransitGatewayPolicyTable",
    "CreateTransitGatewayPrefixListReference",
    "CreateTransitGatewayRoute",
    "CreateTransitGatewayRouteTable",
    "CreateTransitGatewayRouteTableAnnouncement",
    "CreateTransitGatewayVpcAttachment",
    "CreateVerifiedAccessEndpoint",
    "CreateVerifiedAccessGroup",
    "CreateVerifiedAccessInstance",
    "CreateVerifiedAccessTrustProvider",
    "CreateVolume",
    "CreateVpc",
    "CreateVpcEndpoint",
    "CreateVpcEndpointConnectionNotification",
    "CreateVpcEndpointServiceConfiguration",
    "CreateVpcPeeringConnection",
    "CreateVpnConnection",
    "CreateVpnConnectionRoute",
    "CreateVpnGateway",
    "DeleteCarrierGateway",
    "DeleteClientVpnEndpoint",
    "DeleteClientVpnRoute",
    "DeleteCoipCidr",
    "DeleteCoipPool",
    "DeleteCoipPoolPermission",
    "DeleteCustomerGateway",
    "DeleteDhcpOptions",
    "DeleteEgressOnlyInternetGateway",
    "DeleteFleets",
    "DeleteFlowLogs",
    "DeleteFpgaImage",
    "DeleteInstanceConnectEndpoint",
    "DeleteInstanceEventWindow",
    "DeleteInternetGateway",
    "DeleteIpam",
    "DeleteIpamPool",
    "DeleteIpamResourceDiscovery",
    "DeleteIpamScope",
    "DeleteKeyPair",
    "DeleteLaunchTemplate",
    "DeleteLaunchTemplateVersions",
    "DeleteLocalGatewayRoute",
    "DeleteLocalGatewayRouteTable",
    "DeleteLocalGatewayRouteTablePermission",
    "DeleteLocalGatewayRouteTableVirtualInterfaceGroupAssociation",
    "DeleteLocalGatewayRouteTableVpcAssociation",
    "DeleteManagedPrefixList",
    "DeleteNatGateway",
    "DeleteNetworkAcl",
    "DeleteNetworkAclEntry",
    "DeleteNetworkInsightsAccessScope",
    "DeleteNetworkInsightsAccessScopeAnalysis",
    "DeleteNetworkInsightsAnalysis",
    "DeleteNetworkInsightsPath",
    "DeleteNetworkInterface",
    "DeletePlacementGroup",
    "DeletePublicIpv4Pool",
    "DeleteQueuedReservedInstances",
    "DeleteResourcePolicy",
    "DeleteRoute",
    "DeleteRouteTable",
    "DeleteSecurityGroup",
    "DeleteSnapshot",
    "DeleteSpotDatafeedSubscription",
    "DeleteSubnet",
    "DeleteSubnetCidrReservation",
    "DeleteTrafficMirrorFilter",
    "DeleteTrafficMirrorFilterRule",
    "DeleteTrafficMirrorSession",
    "DeleteTrafficMirrorTarget",
    "DeleteTransitGateway",
    "DeleteTransitGatewayConnect",
    "DeleteTransitGatewayConnectPeer",
    "DeleteTransitGatewayMulticastDomain",
    "DeleteTransitGatewayPeeringAttachment",
    "DeleteTransitGatewayPolicyTable",
    "DeleteTransitGatewayPrefixListReference",
    "DeleteTransitGatewayRoute",
    "DeleteTransitGatewayRouteTable",
    "DeleteTransitGatewayRouteTableAnnouncement",
    "DeleteTransitGatewayVpcAttachment",
    "DeleteVerifiedAccessEndpoint",
    "DeleteVerifiedAccessGroup",
    "DeleteVerifiedAccessInstance",
    "DeleteVerifiedAccessTrustProvider",
    "DeleteVolume",
    "DeleteVpc",
    "DeleteVpcEndpointConnectionNotifications",
    "DeleteVpcEndpointServiceConfigurations",
    "DeleteVpcEndpoints",
    "DeleteVpcPeeringConnection",
    "DeleteVpnConnection",
    "DeleteVpnConnectionRoute",
    "DeleteVpnGateway",
    "DeprovisionByoipCidr",
    "DeprovisionIpamPoolCidr",
    "DeprovisionPublicIpv4PoolCidr",
    "DeregisterImage",
    "DeregisterInstanceEventNotificationAttributes",
    "DeregisterTransitGatewayMulticastGroupMembers",
    "DeregisterTransitGatewayMulticastGroupSources",
    "DetachClassicLinkVpc",
    "DetachInternetGateway",
    "DetachNetworkInterface",
    "DetachVerifiedAccessTrustProvider",
    "DetachVolume",
    "DetachVpnGateway",
    "DisableAddressTransfer",
    "DisableAwsNetworkPerformanceMetricSubscription",
    "DisableEbsEncryptionByDefault",
    "DisableFastLaunch",
    "DisableFastSnapshotRestores",
    "DisableImageDeprecation",
    "DisableIpamOrganizationAdminAccount",
    "DisableSerialConsoleAccess",
    "DisableTransitGatewayRouteTablePropagation",
    "DisableVgwRoutePropagation",
    "DisableVpcClassicLink",
    "DisableVpcClassicLinkDnsSupport",
    "DisassociateAddress",
    "DisassociateClientVpnTargetNetwork",
    "DisassociateEnclaveCertificateIamRole",
    "DisassociateIamInstanceProfile",
    "DisassociateInstanceEventWindow",
    "DisassociateIpamResourceDiscovery",
    "DisassociateNatGatewayAddress",
    "DisassociateRouteTable",
    "DisassociateSubnetCidrBlock",
    "DisassociateTransitGatewayMulticastDomain",
    "DisassociateTransitGatewayPolicyTable",
    "DisassociateTransitGatewayRouteTable",
    "DisassociateTrunkInterface",
    "DisassociateVerifiedAccessInstanceWebAcl",
    "DisassociateVpcCidrBlock",
    "EnableAddressTransfer",
    "EnableAwsNetworkPerformanceMetricSubscription",
    "EnableEbsEncryptionByDefault",
    "EnableFastLaunch",
    "EnableFastSnapshotRestores",
    "EnableImageDeprecation",
    "EnableIpamOrganizationAdminAccount",
    "EnableReachabilityAnalyzerOrganizationSharing",
    "EnableSerialConsoleAccess",
    "EnableTransitGatewayRouteTablePropagation",
    "EnableVgwRoutePropagation",
    "EnableVolumeIO",
    "EnableVpcClassicLink",
    "EnableVpcClassicLinkDnsSupport",
    "ExportImage",
    "ExportTransitGatewayRoutes",
    "ImportByoipCidrToIpam",
    "ImportClientVpnClientCertificateRevocationList",
    "ImportImage",
    "ImportInstance",
    "ImportKeyPair",
    "ImportSnapshot",
    "ImportVolume",
    "ModifyAddressAttribute",
    "ModifyAvailabilityZoneGroup",
    "ModifyCapacityReservation",
    "ModifyCapacityReservationFleet",
    "ModifyClientVpnEndpoint",
    "ModifyDefaultCreditSpecification",
    "ModifyEbsDefaultKmsKeyId",
    "ModifyFleet",
    "ModifyFpgaImageAttribute",
    "ModifyHosts",
    "ModifyIdFormat",
    "ModifyIdentityIdFormat",
    "ModifyImageAttribute",
    "ModifyInstanceAttribute",
    "ModifyInstanceCapacityReservationAttributes",
    "ModifyInstanceCreditSpecification",
    "ModifyInstanceEventStartTime",
    "ModifyInstanceEventWindow",
    "ModifyInstanceMaintenanceOptions",
    "ModifyInstanceMetadataOptions",
    "ModifyInstancePlacement",
    "ModifyIpam",
    "ModifyIpamPool",
    "ModifyIpamResourceCidr",
    "ModifyIpamResourceDiscovery",
    "ModifyIpamScope",
    "ModifyLaunchTemplate",
    "ModifyLocalGatewayRoute",
    "ModifyManagedPrefixList",
    "ModifyNetworkInterfaceAttribute",
    "ModifyPrivateDnsNameOptions",
    "ModifyReservedInstances",
    "ModifySecurityGroupRules",
    "ModifySnapshotTier",
    "ModifySpotFleetRequest",
    "ModifySubnetAttribute",
    "ModifyTrafficMirrorFilterNetworkServices",
    "ModifyTrafficMirrorFilterRule",
    "ModifyTrafficMirrorSession",
    "ModifyTransitGateway",
    "ModifyTransitGatewayPrefixListReference",
    "ModifyTransitGatewayVpcAttachment",
    "ModifyVerifiedAccessEndpoint",
    "ModifyVerifiedAccessEndpointPolicy",
    "ModifyVerifiedAccessGroup",
    "ModifyVerifiedAccessGroupPolicy",
    "ModifyVerifiedAccessInstance",
    "ModifyVerifiedAccessInstanceLoggingConfiguration",
    "ModifyVerifiedAccessTrustProvider",
    "ModifyVolume",
    "ModifyVolumeAttribute",
    "ModifyVpcAttribute",
    "ModifyVpcEndpoint",
    "ModifyVpcEndpointConnectionNotification",
    "ModifyVpcEndpointServiceConfiguration",
    "ModifyVpcEndpointServicePayerResponsibility",
    "ModifyVpcPeeringConnectionOptions",
    "ModifyVpcTenancy",
    "ModifyVpnConnection",
    "ModifyVpnConnectionOptions",
    "ModifyVpnTunnelCertificate",
    "ModifyVpnTunnelOptions",
    "MonitorInstances",
    "MoveAddressToVpc",
    "MoveByoipCidrToIpam",
    "PauseVolumeIO",
    "ProvisionByoipCidr",
    "ProvisionIpamPoolCidr",
    "ProvisionPublicIpv4PoolCidr",
    "PurchaseHostReservation",
    "PurchaseReservedInstancesOffering",
    "PurchaseScheduledInstances",
    "PutResourcePolicy",
    "RebootInstances",
    "RegisterImage",
    "RegisterInstanceEventNotificationAttributes",
    "RegisterTransitGatewayMulticastGroupMembers",
    "RegisterTransitGatewayMulticastGroupSources",
    "RejectTransitGatewayMulticastDomainAssociations",
    "RejectTransitGatewayPeeringAttachment",
    "RejectTransitGatewayVpcAttachment",
    "RejectVpcEndpointConnections",
    "RejectVpcPeeringConnection",
    "ReleaseAddress",
    "ReleaseHosts",
    "ReleaseIpamPoolAllocation",
    "ReplaceIamInstanceProfileAssociation",
    "ReplaceNetworkAclAssociation",
    "ReplaceNetworkAclEntry",
    "ReplaceRoute",
    "ReplaceRouteTableAssociation",
    "ReplaceTransitGatewayRoute",
    "ReplaceVpnTunnel",
    "ReportInstanceStatus",
    "RequestSpotFleet",
    "RequestSpotInstances",
    "ResetAddressAttribute",
    "ResetEbsDefaultKmsKeyId",
    "ResetFpgaImageAttribute",
    "ResetImageAttribute",
    "ResetInstanceAttribute",
    "ResetNetworkInterfaceAttribute",
    "RestoreAddressToClassic",
    "RestoreImageFromRecycleBin",
    "RestoreManagedPrefixListVersion",
    "RestoreSnapshotFromRecycleBin",
    "RestoreSnapshotTier",
    "RevokeClientVpnIngress",
    "RevokeSecurityGroupEgress",
    "RevokeSecurityGroupIngress",
    "RunInstances",
    "RunScheduledInstances",
    "SendDiagnosticInterrupt",
    "SendSpotInstanceInterruptions",
    "StartInstances",
    "StartNetworkInsightsAccessScopeAnalysis",
    "StartNetworkInsightsAnalysis",
    "StartVpcEndpointServicePrivateDnsVerification",
    "StopInstances",
    "TerminateClientVpnConnections",
    "TerminateInstances",
    "UnassignIpv6Addresses",
    "UnassignPrivateIpAddresses",
    "UnassignPrivateNatGatewayAddress",
    "UnmonitorInstances",
    "UpdateSecurityGroupRuleDescriptionsEgress",
    "UpdateSecurityGroupRuleDescriptionsIngress",
    "WithdrawByoipCidr"
]
    permissions_management = [
    "CreateNetworkInterfacePermission",
    "DeleteNetworkInterfacePermission",
    "ModifySnapshotAttribute",
    "ModifyVpcEndpointServicePermissions",
    "ResetSnapshotAttribute"
]
    read                   = [
    "ExportClientVpnClientCertificateRevocationList",
    "ExportClientVpnClientConfiguration",
    "GetAssociatedEnclaveCertificateIamRoles",
    "GetAssociatedIpv6PoolCidrs",
    "GetAwsNetworkPerformanceData",
    "GetCapacityReservationUsage",
    "GetCoipPoolUsage",
    "GetConsoleOutput",
    "GetConsoleScreenshot",
    "GetDefaultCreditSpecification",
    "GetEbsDefaultKmsKeyId",
    "GetEbsEncryptionByDefault",
    "GetFlowLogsIntegrationTemplate",
    "GetHostReservationPurchasePreview",
    "GetInstanceUefiData",
    "GetIpamAddressHistory",
    "GetIpamDiscoveredAccounts",
    "GetIpamDiscoveredResourceCidrs",
    "GetIpamPoolCidrs",
    "GetIpamResourceCidrs",
    "GetLaunchTemplateData",
    "GetManagedPrefixListAssociations",
    "GetManagedPrefixListEntries",
    "GetNetworkInsightsAccessScopeAnalysisFindings",
    "GetNetworkInsightsAccessScopeContent",
    "GetPasswordData",
    "GetReservedInstancesExchangeQuote",
    "GetResourcePolicy",
    "GetSerialConsoleAccessStatus",
    "GetSpotPlacementScores",
    "GetSubnetCidrReservations"
]
    list                   = [
    "DescribeAccountAttributes",
    "DescribeAddressTransfers",
    "DescribeAddresses",
    "DescribeAddressesAttribute",
    "DescribeAggregateIdFormat",
    "DescribeAvailabilityZones",
    "DescribeAwsNetworkPerformanceMetricSubscriptions",
    "DescribeBundleTasks",
    "DescribeByoipCidrs",
    "DescribeCapacityReservationFleets",
    "DescribeCapacityReservations",
    "DescribeCarrierGateways",
    "DescribeClassicLinkInstances",
    "DescribeClientVpnAuthorizationRules",
    "DescribeClientVpnConnections",
    "DescribeClientVpnEndpoints",
    "DescribeClientVpnRoutes",
    "DescribeClientVpnTargetNetworks",
    "DescribeCoipPools",
    "DescribeConversionTasks",
    "DescribeCustomerGateways",
    "DescribeDhcpOptions",
    "DescribeEgressOnlyInternetGateways",
    "DescribeElasticGpus",
    "DescribeExportImageTasks",
    "DescribeExportTasks",
    "DescribeFastLaunchImages",
    "DescribeFastSnapshotRestores",
    "DescribeFleetHistory",
    "DescribeFleetInstances",
    "DescribeFleets",
    "DescribeFlowLogs",
    "DescribeFpgaImageAttribute",
    "DescribeFpgaImages",
    "DescribeHostReservationOfferings",
    "DescribeHostReservations",
    "DescribeHosts",
    "DescribeIamInstanceProfileAssociations",
    "DescribeIdFormat",
    "DescribeIdentityIdFormat",
    "DescribeImageAttribute",
    "DescribeImages",
    "DescribeImportImageTasks",
    "DescribeImportSnapshotTasks",
    "DescribeInstanceAttribute",
    "DescribeInstanceConnectEndpoints",
    "DescribeInstanceCreditSpecifications",
    "DescribeInstanceEventNotificationAttributes",
    "DescribeInstanceEventWindows",
    "DescribeInstanceStatus",
    "DescribeInstanceTypeOfferings",
    "DescribeInstanceTypes",
    "DescribeInstances",
    "DescribeInternetGateways",
    "DescribeIpamPools",
    "DescribeIpamResourceDiscoveries",
    "DescribeIpamResourceDiscoveryAssociations",
    "DescribeIpamScopes",
    "DescribeIpams",
    "DescribeIpv6Pools",
    "DescribeKeyPairs",
    "DescribeLaunchTemplateVersions",
    "DescribeLaunchTemplates",
    "DescribeLocalGatewayRouteTablePermissions",
    "DescribeLocalGatewayRouteTableVirtualInterfaceGroupAssociations",
    "DescribeLocalGatewayRouteTableVpcAssociations",
    "DescribeLocalGatewayRouteTables",
    "DescribeLocalGatewayVirtualInterfaceGroups",
    "DescribeLocalGatewayVirtualInterfaces",
    "DescribeLocalGateways",
    "DescribeManagedPrefixLists",
    "DescribeMovingAddresses",
    "DescribeNatGateways",
    "DescribeNetworkAcls",
    "DescribeNetworkInsightsAccessScopeAnalyses",
    "DescribeNetworkInsightsAccessScopes",
    "DescribeNetworkInsightsAnalyses",
    "DescribeNetworkInsightsPaths",
    "DescribeNetworkInterfaceAttribute",
    "DescribeNetworkInterfacePermissions",
    "DescribeNetworkInterfaces",
    "DescribePlacementGroups",
    "DescribePrefixLists",
    "DescribePrincipalIdFormat",
    "DescribePublicIpv4Pools",
    "DescribeRegions",
    "DescribeReplaceRootVolumeTasks",
    "DescribeReservedInstances",
    "DescribeReservedInstancesListings",
    "DescribeReservedInstancesModifications",
    "DescribeReservedInstancesOfferings",
    "DescribeRouteTables",
    "DescribeScheduledInstanceAvailability",
    "DescribeScheduledInstances",
    "DescribeSecurityGroupReferences",
    "DescribeSecurityGroupRules",
    "DescribeSecurityGroups",
    "DescribeSnapshotAttribute",
    "DescribeSnapshotTierStatus",
    "DescribeSnapshots",
    "DescribeSpotDatafeedSubscription",
    "DescribeSpotFleetInstances",
    "DescribeSpotFleetRequestHistory",
    "DescribeSpotFleetRequests",
    "DescribeSpotInstanceRequests",
    "DescribeSpotPriceHistory",
    "DescribeStaleSecurityGroups",
    "DescribeStoreImageTasks",
    "DescribeSubnets",
    "DescribeTags",
    "DescribeTrafficMirrorFilters",
    "DescribeTrafficMirrorSessions",
    "DescribeTrafficMirrorTargets",
    "DescribeTransitGatewayAttachments",
    "DescribeTransitGatewayConnectPeers",
    "DescribeTransitGatewayConnects",
    "DescribeTransitGatewayMulticastDomains",
    "DescribeTransitGatewayPeeringAttachments",
    "DescribeTransitGatewayPolicyTables",
    "DescribeTransitGatewayRouteTableAnnouncements",
    "DescribeTransitGatewayRouteTables",
    "DescribeTransitGatewayVpcAttachments",
    "DescribeTransitGateways",
    "DescribeTrunkInterfaceAssociations",
    "DescribeVerifiedAccessEndpoints",
    "DescribeVerifiedAccessGroups",
    "DescribeVerifiedAccessInstanceLoggingConfigurations",
    "DescribeVerifiedAccessInstanceWebAclAssociations",
    "DescribeVerifiedAccessInstances",
    "DescribeVerifiedAccessTrustProviders",
    "DescribeVolumeAttribute",
    "DescribeVolumeStatus",
    "DescribeVolumes",
    "DescribeVolumesModifications",
    "DescribeVpcAttribute",
    "DescribeVpcClassicLink",
    "DescribeVpcClassicLinkDnsSupport",
    "DescribeVpcEndpointConnectionNotifications",
    "DescribeVpcEndpointConnections",
    "DescribeVpcEndpointServiceConfigurations",
    "DescribeVpcEndpointServicePermissions",
    "DescribeVpcEndpointServices",
    "DescribeVpcEndpoints",
    "DescribeVpcPeeringConnections",
    "DescribeVpcs",
    "DescribeVpnConnections",
    "DescribeVpnGateways",
    "GetGroupsForCapacityReservation",
    "GetInstanceTypesFromInstanceRequirements",
    "GetIpamPoolAllocations",
    "GetTransitGatewayAttachmentPropagations",
    "GetTransitGatewayMulticastDomainAssociations",
    "GetTransitGatewayPolicyTableAssociations",
    "GetTransitGatewayPolicyTableEntries",
    "GetTransitGatewayPrefixListReferences",
    "GetTransitGatewayRouteTableAssociations",
    "GetTransitGatewayRouteTablePropagations",
    "GetVerifiedAccessEndpointPolicy",
    "GetVerifiedAccessGroupPolicy",
    "GetVerifiedAccessInstanceWebAcl",
    "GetVpnConnectionDeviceSampleConfiguration",
    "GetVpnConnectionDeviceTypes",
    "GetVpnTunnelReplacementStatus",
    "ListImagesInRecycleBin",
    "ListSnapshotsInRecycleBin",
    "SearchLocalGatewayRoutes",
    "SearchTransitGatewayMulticastGroups",
    "SearchTransitGatewayRoutes"
]
    tagging                = [
    "CreateTags",
    "DeleteTags"
]
  }
}
