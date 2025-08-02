/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/sns-topic

  DESCRIPTION:
    Local values for the SNS topic module, including default tags and computed
    values for resource configuration.
----------------------------------------------------------------------------- */

locals {
  topic_tags = merge({
    "ManagedBy" = "tfbox"
  }, var.tags)
}
