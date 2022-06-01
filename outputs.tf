output "services" {
  description = "Contains a map of service names. Each service name contains another map of access levels which yield a list of action string e.g. service.iam.write"
  value       = local.actions
}
