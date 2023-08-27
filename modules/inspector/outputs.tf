output "actions" {
  description = "Contains a map of access levels (write, permissions_management, read, list and tagging) which yield a list of action strings."
  value       = local.actions
}
