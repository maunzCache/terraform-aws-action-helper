module "cloudfront" {
  ###
  # Output:
  ###
  # cloudfront_actions = {
  #   list = [
  #     "cloudfront:ListDistributions",
  #     "cloudfront:ListDistributionsByCachePolicyId",
  #     "cloudfront:ListDistributionsByKeyGroup",
  #     "cloudfront:ListDistributionsByLambdaFunction",
  #     "cloudfront:ListDistributionsByOriginRequestPolicyId",
  #     "cloudfront:ListDistributionsByRealtimeLogConfig",
  #     "cloudfront:ListDistributionsByResponseHeadersPolicyId",
  #     "cloudfront:ListDistributionsByWebACLId",
  #     "cloudfront:ListStreamingDistributions",
  #   ]
  #   permissions_management = []
  #   read = [
  #     "cloudfront:GetDistribution",
  #     "cloudfront:GetDistributionConfig",
  #     "cloudfront:GetStreamingDistribution",
  #     "cloudfront:GetStreamingDistributionConfig",
  #   ]
  #   tagging = []
  #   write = [
  #     "cloudfront:CopyDistribution",
  #     "cloudfront:CreateDistribution",
  #     "cloudfront:CreateStreamingDistribution",
  #     "cloudfront:CreateStreamingDistributionWithTags",
  #     "cloudfront:DeleteDistribution",
  #     "cloudfront:DeleteStreamingDistribution",
  #     "cloudfront:UpdateDistribution",
  #     "cloudfront:UpdateStreamingDistribution",
  #   ]
  # }

  source = "../../modules/cloudfront"

  use_prefix = var.use_prefix

  filter_actions = true
  filtering = {
    starts_with = ""
    contains    = "Distribution"
    ends_with   = ""
  }

  minify_strings     = false
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

module "dynamodb" {
  ###
  # Output:
  ###
  # dynamodb_actions = {
  #   list                   = []
  #   permissions_management = []
  #   read = [
  #     "dynamodb:DescribeGlobalTable",
  #     "dynamodb:DescribeTable",
  #   ]
  #   tagging = []
  #   write = [
  #     "dynamodb:CreateGlobalTable",
  #     "dynamodb:CreateTable",
  #     "dynamodb:DeleteTable",
  #     "dynamodb:ImportTable",
  #     "dynamodb:UpdateGlobalTable",
  #     "dynamodb:UpdateTable",
  #   ]
  # }

  source = "../../modules/dynamodb"

  use_prefix = var.use_prefix

  filter_actions = true
  filtering = {
    starts_with = ""
    contains    = ""
    ends_with   = "Table"
  }

  minify_strings     = false
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

module "ec2" {
  ###
  # Output:
  ###
  # ec2_actions = {
  #   list                   = []
  #   permissions_management = []
  #   read                   = []
  #   tagging                = []
  #   write = [
  #     "ec2:CreateTransitGateway",
  #     "ec2:CreateTransitGatewayConnect",
  #     "ec2:CreateTransitGatewayConnectPeer",
  #     "ec2:CreateTransitGatewayMulticastDomain",
  #     "ec2:CreateTransitGatewayPeeringAttachment",
  #     "ec2:CreateTransitGatewayPolicyTable",
  #     "ec2:CreateTransitGatewayPrefixListReference",
  #     "ec2:CreateTransitGatewayRoute",
  #     "ec2:CreateTransitGatewayRouteTable",
  #     "ec2:CreateTransitGatewayRouteTableAnnouncement",
  #     "ec2:CreateTransitGatewayVpcAttachment",
  #   ]
  # }

  source = "../../modules/ec2"

  use_prefix = var.use_prefix

  filter_actions = true
  filtering = {
    starts_with = "CreateTransit"
    contains    = ""
    ends_with   = ""
  }

  minify_strings     = false
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}
