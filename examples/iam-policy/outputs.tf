output "iam_policy_example" {
  description = "Example IAM policy for S3."
  value       = data.aws_iam_policy_document.example
}
