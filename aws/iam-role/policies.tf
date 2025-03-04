/* --------------------------------------------------------
ARQUIVO: policies.tf @ aws/iam module

Definição e gerenciamento de processos para declaração e
implantação de policies IAM a serem vinculadas à role
criada com a chamada deste módulo
-------------------------------------------------------- */

# Renderizando templates de policies previamente definidos pelo usuário
resource "template_dir" "policies_templates" {
  source_dir      = var.policy_templates_source_dir
  destination_dir = local.policies_templates_destination_dir
  vars            = var.policy_templates_vars
}

# Obtendo arquivos renderizados em data source que representa arquivos locais
data "local_file" "policies_files" {
  for_each = local.templates_filepaths
  filename = each.value

  depends_on = [
    template_dir.policies_templates
  ]
}

# Criando policies IAM para cada template disponibilizado
resource "aws_iam_policy" "policies" {
  for_each = data.local_file.policies_files
  name     = each.key
  policy   = each.value.content

  depends_on = [
    template_dir.policies_templates,
    data.local_file.policies_files
  ]
}

