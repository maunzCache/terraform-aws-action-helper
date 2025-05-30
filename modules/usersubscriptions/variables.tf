variable "use_prefix" {
  type        = bool
  default     = true
  description = "Whether to include the service prefix in the action string e. g. iam:TagResource (if true) or TagResource (if false)"
}

##########
# Filter #
##########
variable "filter_actions" {
  type        = bool
  default     = false
  description = "Whether the actions strings should be filtered by substrings defined in filtering."
}

variable "filtering" {
  type = object({
    starts_with = string
    contains    = string
    ends_with   = string
  })
  default = {
    starts_with = ""
    contains    = ""
    ends_with   = ""
  }
  description = "Allows to filter by substrings if filter_actions is true. If no value is given (empty string), no filtering will be done."
}

##########
# Minify #
##########
variable "minify_strings" {
  type        = bool
  default     = true
  description = "Whether to summarize actions by a regular expression or not."
}

variable "minify_regex" {
  type        = string
  default     = "/([A-Z][^A-Z]+).+/"
  description = "Expression by which the aciton name is filtered. Add capturing groups for potential replacements."
}

variable "minify_replacement" {
  type        = string
  default     = "$1*"
  description = "Expression which represents the replacement value for the match of the minify_regex."
}
