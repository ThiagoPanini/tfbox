/* --------------------------------------------------------
ARQUIVO: variables.tf @ aws/iam module

Variáveis utilizadas no módulo aws/iam para definição,
criação e configuração de policies e roles IAM de serviço.
-------------------------------------------------------- */

variable "role_name" {
  description = "Nome da role IAM a ser criada."
  type        = string
}

variable "trust_policy_filepath" {
  description = "Caminho para o arquivo JSON que define a trust policy a ser associada à role."
  type        = string
}

variable "policy_templates_source_dir" {
  description = "Diretório de entrada contendo todos os templates definidos para criação das policies IAM."
  type        = string
}

variable "policy_templates_destination_dir" {
  description = "Diretório de saída a ser utilizado para armazenar todos os arquivos de templates já renderizados após a substituição das variáveis. Se não passado de forma explícita, o diretório de saída dos templates será criado automaticamente pelo módulo no mesmo nível do caminho definido em var.policies_templates_source_dir"
  type        = string
  default     = ""
}

variable "policy_templates_vars" {
  description = "Variáveis e seus respectivos valores a serem substituídos nos templates de policies fornecidos."
  type        = map(string)
}

variable "existent_policy_arns" {
  description = "ARNs de policies IAM já existentes a serem vinculadas na role criada através da chamada desde módulo."
  type        = list(string)
  default     = []
}




