# AWS action helper

**aws-action-helper** is a Terraform module which helps implementing AWS IAM policies by providing abstracting actions (or permissions) as usable object in Terraform. All information is based on <https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html>.

It also comes with a python script allowing to update the module on the fly if AWS services are added or changed. This allows to track updates to services and especially IAM policies.

## Rational

During a project of mine I was frustated that there was no good way to manage the names of actions that can be used within an IAM policy. As the project team does not prefer data sources, I implemented a solution as Terraform module.

The benefit of this module is that you can now manage all actions yourself thus you may never add new actions accidentally and restrict permissions managed by Terraform to what is inside your code.
A slightly downside is, however, that using this in a bigger project will result in a lot of additional stub code to be able to access the required outputs.

## Module usage

To use the module simply reference it from github. Access to the output it granted via the variable `services`. The next level is the AWS service name abbreviation, which matches the service prefix value e.g. ec2, iam, ... . The service map separates actions into one of five categories:

1. list
2. permissions_management
3. read
4. tagging
5. write

Each of category yields a list with the action names.

Example:

```hcl
module "aws_action_helper" {
  source = "https://github.com/maunzCache/aws-action-helper"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = var.filtering

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}

data "aws_iam_policy_document" "example" {
  statement {
    sid = "AllowAllS3WriteActions"

    actions = module.aws_action_helper.services.s3.write

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}
```

## Module examples

Below you can find a few use cases for built-in features.

## Minification

The module allows for minification of action names which is commonly used when summarizing IAM policies. Currently the only useful placeholder is `*`.

The replacement can be fully customizied by overriding the regular expression for the lookup and the replacement. By default, the module will try to lookup the first uppercase word and replace the rest with an `*`.

Example:

```hcl
module "aws_action_helper" {
  source = "https://github.com/maunzCache/aws-action-helper"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = {
    starts_with = "Create"
    contains    = ""
    ends_with   = ""
  }

  minify_strings     = var.minify_strings
  minify_regex       = "/([A-Z][^A-Z]+).+/" # Find first uppercase word
  minify_replacement = "$1*"                # Replace tail with *
}
```

Returns:

```hcl
services = {
  ec2 = {
    "list"                   = []
    "permissions_management" = [
      "ec2:Create*",
    ]
    "read"                   = []
    "tagging"                = [
      "ec2:Create*",
    ]
    "write"                  = [
      "ec2:Create*",
    ]
  }
}
```

### Filtering

Another included feature is the filtering of actions before creating output. Action names can be filtered by:

1. **starts_with**: The actions name starts with this sting
2. **contains**: The actions name contains this substing
3. **ends_with**: The actions name end with this sting

The order of evaluation matches the order of the above list. So be careful if you want to mix filters.

Additionally, minification can also be used with filtering. However, the default minification may yield unwanted results or at least not the best optimization.

#### starts_with

Example:

```hcl
module "aws_action_helper" {
  source = "https://github.com/maunzCache/aws-action-helper"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = {
    starts_with = "Get"
    contains    = ""
    ends_with   = ""
  }

  minify_strings     = var.minify_strings
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}
```

Returns:

```hcl
services = {
  ec2 = {
    "list"                   = [
      "ec2:Get*",
    ]
    "permissions_management" = []
    "read"                   = [
      "ec2:Get*",
    ]
    "tagging"                = []
    "write"                  = []
  }
}
```

#### contains

Example:

```hcl
module "aws_action_helper" {
  source = "https://github.com/maunzCache/aws-action-helper"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = {
    starts_with = ""
    contains    = "Instance"
    ends_with   = ""
  }

  # Note: Using default minification results in side effects
  minify_strings     = false
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}
```

Returns:

```hcl
services = {
  ec2 = {
    "list"                   = [
      "ec2:DescribeClassicLinkInstances",
      "ec2:DescribeFleetInstances",
      "ec2:DescribeIamInstanceProfileAssociations",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceCreditSpecifications",
      "ec2:DescribeInstanceEventNotificationAttributes",
      "ec2:DescribeInstanceEventWindows",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeReservedInstances",
      "ec2:DescribeReservedInstancesListings",
      "ec2:DescribeReservedInstancesModifications",
      "ec2:DescribeReservedInstancesOfferings",
      "ec2:DescribeSpotFleetInstances",
      "ec2:DescribeSpotInstanceRequests",
    ]
    "permissions_management" = []
    "read"                   = [
      "ec2:DescribeScheduledInstanceAvailability",
      "ec2:DescribeScheduledInstances",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "ec2:GetReservedInstancesExchangeQuote",
    ]
    "tagging"                = []
    "write"                  = [
      "ec2:AcceptReservedInstancesExchangeQuote",
      "ec2:AssociateIamInstanceProfile",
      "ec2:AssociateInstanceEventWindow",
      "ec2:BundleInstance",
      "ec2:CancelReservedInstancesListing",
      "ec2:CancelSpotInstanceRequests",
      "ec2:ConfirmProductInstance",
      "ec2:CreateInstanceEventWindow",
      "ec2:CreateInstanceExportTask",
      "ec2:CreateReservedInstancesListing",
      "ec2:DeleteInstanceEventWindow",
      "ec2:DeleteQueuedReservedInstances",
      "ec2:DeregisterInstanceEventNotificationAttributes",
      "ec2:DisassociateIamInstanceProfile",
      "ec2:DisassociateInstanceEventWindow",
      "ec2:ImportInstance",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyInstanceCapacityReservationAttributes",
      "ec2:ModifyInstanceCreditSpecification",
      "ec2:ModifyInstanceEventStartTime",
      "ec2:ModifyInstanceEventWindow",
      "ec2:ModifyInstanceMaintenanceOptions",
      "ec2:ModifyInstanceMetadataOptions",
      "ec2:ModifyInstancePlacement",
      "ec2:ModifyReservedInstances",
      "ec2:MonitorInstances",
      "ec2:PurchaseReservedInstancesOffering",
      "ec2:PurchaseScheduledInstances",
      "ec2:RebootInstances",
      "ec2:RegisterInstanceEventNotificationAttributes",
      "ec2:ReplaceIamInstanceProfileAssociation",
      "ec2:ReportInstanceStatus",
      "ec2:RequestSpotInstances",
      "ec2:ResetInstanceAttribute",
      "ec2:RunInstances",
      "ec2:RunScheduledInstances",
      "ec2:SendSpotInstanceInterruptions",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:UnmonitorInstances",
    ]
  }
}
```

#### end_with

Example:

```hcl
module "aws_action_helper" {
  source = "https://github.com/maunzCache/aws-action-helper"

  use_prefix = var.use_prefix

  filter_actions = var.filter_actions
  filtering      = {
    starts_with = ""
    contains    = ""
    ends_with   = "Instances"
  }

  # Note: Using default minification results in side effects
  minify_strings     = false
  minify_regex       = var.minify_regex
  minify_replacement = var.minify_replacement
}
```

Returns:

```hcl
services = {
  ec2 = {
    "list"                   = [
      "ec2:DescribeClassicLinkInstances",
      "ec2:DescribeFleetInstances",
      "ec2:DescribeInstances",
      "ec2:DescribeReservedInstances",
      "ec2:DescribeSpotFleetInstances",
    ]
    "permissions_management" = []
    "read"                   = [
      "ec2:DescribeScheduledInstances",
    ]
    "tagging"                = []
    "write"                  = [
      "ec2:DeleteQueuedReservedInstances",
      "ec2:ModifyReservedInstances",
      "ec2:MonitorInstances",
      "ec2:PurchaseScheduledInstances",
      "ec2:RebootInstances",
      "ec2:RequestSpotInstances",
      "ec2:RunInstances",
      "ec2:RunScheduledInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:UnmonitorInstances",
    ]
  }
}
```

## Module generation

This repository also contains a python script in the `.generate/` directory to add or update submodules for this project using [cookiecutter](https://github.com/cookiecutter/cookiecutter).

Please note that the script is fragile in regards to getting the information. As of now, AWS decided to not release the information about action names - or in general permissions - in a way that can be programmatically accessed. Thus a script was written to parse the current documentation page of all services which luckily is created in a persistent manner.

### Usage

Ensure to install all python dependencies first

```shell
python3 -m pip install -r requirements.txt
```

To generate or cache the latest information about a service use the following call:

```shell
cd .generate/
./generate_module.py --docs-page list_amazonec2
```

This call will only write a cache file for upcoming calls of the script.

The `--docs-page` argument represents the filename of the docs page which has to be accessed by the script. If you ran the example, you can find a list of all pages in the generated file `service_list.json`. Otherwise you need to take a look at the [AWS documentation HTML source](https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html).

If you want to update or generate a new module, simply add the`--generate` parameter:

```shell
cd .generate/
./generate_module.py --docs-page list_amazonec2 --generate
```

This will create or replace a directory in the `modules/` directory. To be able to access this module you'll need to update the `main.tf` file locals section:

```hcl
locals {
  generate_dynamodb = contains(var.generate_services, "dynamodb")
  generate_ec2      = contains(var.generate_services, "ec2")
  generate_iam      = contains(var.generate_services, "iam")

  // Helper to avoid output if actions should not be rendered
  generate_actions = {
    dynamodb = local.generate_dynamodb == true ? module.dynamodb[0].actions : {}
    ec2      = local.generate_ec2 == true ? module.ec2[0].actions : {}
    iam      = local.generate_iam == true ? module.iam[0].actions : {}
  }

  # ...
}
```

And additionally put the service name into the `generate_services` variable in `variables.tf`:

```hcl
variable "generate_services" {
  type        = list(string)
  default     = ["dynamodb", "ec2", "iam"]
  description = "List of submodules to use for action list generation."
}
```

## Contributing

If you find and bugs, have recommendations or want to add/update a module, feel free to add a pull request or create an issue.

I prefer test driven development as well as clean code, so if you need to update any code, please try to stick to the current code style and provide testing.

<!-- Generated tf-docs code -->

## License

This project uses the **Apache License Version 2.0**. See [LICENSE](LICENSE) for more information.
