variable "use_prefix" {
  type        = bool
  default     = true
  description = "TODO"
}

// TODO: Replace with general wildcard and allow to override regex
// Also implement filtering
variable "minify_strings" {
  type        = bool
  default     = true
  description = "TODO"
}

############
# Generate #
############
// TODO: Replace with map
variable "generate_ec2" {
  type        = bool
  default     = true
  description = "TODO"
}
