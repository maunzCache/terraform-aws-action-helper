module "s3" {
  source = "../../modules/s3"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = false
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

locals {
  s3_bucket_name = "my-bucket"
}

# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#example-usage
data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = module.s3.actions.list

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = module.s3.actions.read

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = concat(
      module.s3.actions.write,
      module.s3.actions.permissions_management,
      module.s3.actions.read,
      module.s3.actions.list,
      module.s3.actions.tagging,
    )

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}/home/&{aws:username}",
      "arn:aws:s3:::${local.s3_bucket_name}/home/&{aws:username}/*",
    ]
  }
}
