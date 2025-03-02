/* --------------------------------------------------------
ARQUIVO: variables.tf @ aws/iam module

Variáveis utilizadas no módulo aws/iam para definição,
criação e configuração de policies e roles IAM de serviço.
-------------------------------------------------------- */

variable "policies_templates_source_dir" {
  description = "Diretório de entrada contendo todos os templates definidos para criação das policies IAM."
  type        = string
}

variable "policies_templates_destination_dir" {
  description = "Diretório de saída a ser utilizado para armazenar todos os arquivos de templates já renderizados após a substituição das variáveis. Se não passado de forma explícita, o diretório de saída dos templates será criado automaticamente pelo módulo no mesmo nível do caminho definido em var.policies_templates_source_dir"
  type        = string
  default     = ""
}

variable "policies_templates_vars" {
  description = "Variáveis e seus respectivos valores a serem substituídos nos templates de policies fornecidos."
  type        = map(string)
}
