/* -----------------------------------------------------------------------------
  FILE: role.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    This Terraform file defines resources for creating and managing an AWS IAM role.
    It supports the declaration of a trust policy, the attachment of inline policies,
    and the association of existing IAM policies by ARN.

  RESOURCES:
    - aws_iam_role.this:
        Provisions an IAM role with a trust policy loaded from an external file.
        The trust policy specifies which entities are allowed to assume the role.

    - aws_iam_role_policy_attachment.inline_attachments:
        Attaches inline IAM policies, created within the module, to the IAM role.
        Utilizes a for_each construct for multiple policy attachments and ensures
        proper dependency ordering.

    - aws_iam_role_policy_attachment.existent_attachment:
        Attaches existing IAM policies, identified by their ARNs, to the IAM role.
        Supports multiple attachments using a for_each construct.
----------------------------------------------------------------------------- */

# Create IAM role with specified trust policy
resource "aws_iam_role" "this" {
  name                  = var.role_name
  assume_role_policy    = file(var.trust_policy_filepath)
  force_detach_policies = true
  tags                  = var.tags
}

# Attach inline policies created within the module to the IAM role
resource "aws_iam_role_policy_attachment" "inline_attachments" {
  for_each   = aws_iam_policy.policies
  role       = aws_iam_role.this.name
  policy_arn = each.value.arn

  depends_on = [
    aws_iam_policy.policies
  ]
}

# Attach existing IAM policies (by ARN) to the IAM role
resource "aws_iam_role_policy_attachment" "existent_attachment" {
  for_each   = { for arn in var.existent_policy_arns : arn => arn }
  role       = aws_iam_role.this.name
  policy_arn = each.value
}
