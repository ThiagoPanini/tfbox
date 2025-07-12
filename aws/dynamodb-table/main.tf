/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/dynamodb-table

  DESCRIPTION:
    This Terraform module provisions an AWS DynamoDB table with configurable
    attributes, billing mode, and key schema. The table's properties such as
    name, billing mode, hash key, range key, and attribute definitions are
    parameterized via input variables, allowing for flexible deployments.

  RESOURCES:
    - aws_dynamodb_table.this: Creates a DynamoDB table using the provided
      configuration.
----------------------------------------------------------------------------- */

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
