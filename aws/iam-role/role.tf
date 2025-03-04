/* --------------------------------------------------------
ARQUIVO: role.tf @ aws/iam module

Definição e gerenciamento de processos para declaração e
implantação de uma role IAM.
-------------------------------------------------------- */

# Definindo role com uma trust policy
resource "aws_iam_role" "this" {
  name                  = var.role_name
  assume_role_policy    = file(var.trust_policy_path)
  force_detach_policies = true
}

# Vinculando policies criadas no módulo à role
resource "aws_iam_role_policy_attachment" "inline_attachments" {
  for_each   = aws_iam_policy.policies
  role       = aws_iam_role.this.name
  policy_arn = each.value.arn

  depends_on = [
    aws_iam_policy.policies
  ]
}

# Vinculando policies já existentes no módulo à role
resource "aws_iam_role_policy_attachment" "existent_attachment" {
  for_each   = { for arn in var.existent_policies_arns : arn => arn }
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

