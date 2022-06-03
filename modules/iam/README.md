<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| filter\_actions | Whether the actions strings should be filtered by substrings defined in filtering. | `bool` | `false` | no |
| filtering | Allows to filter by substrings if filter\_actions is true. If no value is given (empty string), no filtering will be done. | ```object({ starts_with = string contains = string ends_with = string })``` | ```{ "contains": "", "ends_with": "", "starts_with": "" }``` | no |
| minify\_regex | Expression by which the aciton name is filtered. Add capturing groups for potential replacements. | `string` | `"/([A-Z][^A-Z]+).+/"` | no |
| minify\_replacement | Expression which represents the replacement value for the match of the minify\_regex. | `string` | `"$1*"` | no |
| minify\_strings | Whether to summarize actions by a regular expression or not. | `bool` | `true` | no |
| use\_prefix | Whether to include the service prefix in the action string e. g. iam:TagResource (if true) or TagResource (if false) | `bool` | `true` | no |

## Modules

No modules.

## Resources

No resources.
<!-- END_TF_DOCS -->
