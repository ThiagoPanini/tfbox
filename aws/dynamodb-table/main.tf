/* --------------------------------------------------------
ARQUIVO: main.tf @ aws/dynamodb-table module

Definição e aplicação de regras necessárias para criação
e implantação de uma tabela pré configurada no DynamoDB.
-------------------------------------------------------- */

resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

}
