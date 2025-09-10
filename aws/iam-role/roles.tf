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
resource "aws_iam_role" "roles" {
  for_each              = { for role in var.roles_config : role.role_name => role }
  name                  = each.value.role_name
  assume_role_policy    = file(each.value.trust_policy_filepath)
  force_detach_policies = true
  tags                  = var.tags

  depends_on = [
    aws_iam_policy.policies
  ]
}

# Applying policy attachments to roles
resource "aws_iam_role_policy_attachment" "policies_attachments" {
  for_each   = local.roles_and_policies_attachments
  role       = each.value.role_name
  policy_arn = each.value.policy_name

  depends_on = [
    aws_iam_role.roles,
    aws_iam_policy.policies
  ]

}
