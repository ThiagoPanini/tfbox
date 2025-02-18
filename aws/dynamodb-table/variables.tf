/* --------------------------------------------------------
ARQUIVO: variables.tf @ get-active-tickers module

Variáveis utilizadas no módulo aws/dynamodb-table para
definição e criação de tabelas no DynamoDB
-------------------------------------------------------- */

variable "name" {
  description = "[REQUIRED] Nome da tabela a ser criada no DynamoDB"
  type        = string
}


variable "billing_mode" {
  description = "Tipo de cobrança associada ao consumo dos itens da tabela criada"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = var.table_billing_mode == "PROVISIONED" || var.table_billing_mode == "PAY_PER_REQUEST"
    error_message = "O valor da variável deve ser 'PROVISIONED' ou 'PAY_PER_REQUEST'."
  }
}
