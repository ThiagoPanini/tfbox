/* --------------------------------------------------------
ARQUIVO: variables.tf @ get-active-tickers module

Variáveis utilizadas no módulo aws/dynamodb-table para
definição e criação de tabelas no DynamoDB
-------------------------------------------------------- */

variable "name" {
  description = "Nome da tabela a ser criada no DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Nome de atributo a ser utilizado como chave primária (hash key) da tabela"
  type        = string
}

variable "range_key" {
  description = "Nome de atributo a ser utilizado como segunda parte da chave secundária (range key) da tabela"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Lista de maps contendo informações sobre os atributos da tabela no formato [{'name': 'field_name', 'type': 'field_type'}]. Todos os índices definidos para a tabela (hash key e range key) devem, obrigatoriamente, estarem contidos como elementos dessa lista de atributos."
  type        = list(map(string))
  default     = []

  validation {
    condition = alltrue([
      for type in distinct([
        for attribute_map in var.attributes : attribute_map.type
      ]) : contains(["S", "N", "B"], type)
    ])
    error_message = "Os atributos de uma tabela do DynamoDB precisam ser definidos com tipos primitivos que referem-se a: 'S' para strings, 'N' para numéricos e 'B' para binários."
  }
}

variable "billing_mode" {
  description = "Tipo de cobrança associada ao consumo dos itens da tabela criada"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = var.billing_mode == "PROVISIONED" || var.billing_mode == "PAY_PER_REQUEST"
    error_message = "O valor da variável deve ser 'PROVISIONED' ou 'PAY_PER_REQUEST'."
  }
}
