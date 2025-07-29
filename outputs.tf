/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    Outputs for the IAM role module, including role name, ARN, and attached
    policy ARNs.
----------------------------------------------------------------------------- */

output "role_name" {
  description = "Name of the IAM role."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role."
  value       = aws_iam_role.this.arn
}

output "attached_policy_arns" {
  description = "List of ARNs for policies attached to the IAM role."
  value       = [for a in aws_iam_role_policy_attachment.inline_attachments : a.policy_arn]
}
