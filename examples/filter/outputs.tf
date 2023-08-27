output "cloudfront_actions" {
  description = "Contains a map of access levels (write, permissions_management, read, list and tagging) which yield a list of action strings."
  value       = module.cloudfront.actions
}

output "dynamodb_actions" {
  description = "Contains a map of access levels (write, permissions_management, read, list and tagging) which yield a list of action strings."
  value       = module.dynamodb.actions
}

output "ec2_actions" {
  description = "Contains a map of access levels (write, permissions_management, read, list and tagging) which yield a list of action strings."
  value       = module.ec2.actions
}
