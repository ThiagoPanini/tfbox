/* --------------------------------------------------------
FILE: role.tf @ aws/iam module

Definition and management of processes for declaration and
deployment of an IAM role.
-------------------------------------------------------- */

# Defining role with a trust policy
resource "aws_iam_role" "this" {
  name                  = var.role_name
  assume_role_policy    = file(var.trust_policy_filepath)
  force_detach_policies = true
}

# Linking policies created in the module to the role
resource "aws_iam_role_policy_attachment" "inline_attachments" {
  for_each   = aws_iam_policy.policies
  role       = aws_iam_role.this.name
  policy_arn = each.value.arn

  depends_on = [
    aws_iam_policy.policies
  ]
}

# Linking existing policies in the module to the role
resource "aws_iam_role_policy_attachment" "existent_attachment" {
  for_each   = { for arn in var.existent_policy_arns : arn => arn }
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

