# simspaceweaver

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_filter_actions"></a> [filter\_actions](#input\_filter\_actions) | Whether the actions strings should be filtered by substrings defined in filtering. | `bool` | `false` | no |
| <a name="input_filtering"></a> [filtering](#input\_filtering) | Allows to filter by substrings if filter\_actions is true. If no value is given (empty string), no filtering will be done. | <pre>object({<br>    starts_with = string<br>    contains    = string<br>    ends_with   = string<br>  })</pre> | <pre>{<br>  "contains": "",<br>  "ends_with": "",<br>  "starts_with": ""<br>}</pre> | no |
| <a name="input_minify_regex"></a> [minify\_regex](#input\_minify\_regex) | Expression by which the aciton name is filtered. Add capturing groups for potential replacements. | `string` | `"/([A-Z][^A-Z]+).+/"` | no |
| <a name="input_minify_replacement"></a> [minify\_replacement](#input\_minify\_replacement) | Expression which represents the replacement value for the match of the minify\_regex. | `string` | `"$1*"` | no |
| <a name="input_minify_strings"></a> [minify\_strings](#input\_minify\_strings) | Whether to summarize actions by a regular expression or not. | `bool` | `true` | no |
| <a name="input_use_prefix"></a> [use\_prefix](#input\_use\_prefix) | Whether to include the service prefix in the action string e. g. iam:TagResource (if true) or TagResource (if false) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_actions"></a> [actions](#output\_actions) | Contains a map of access levels (write, permissions\_management, read, list and tagging) which yield a list of action strings. |
<!-- END_TF_DOCS -->
