/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/sns-topic

  DESCRIPTION:
    This Terraform module provisions AWS SNS topics with flexible configuration
    options. It supports standard and FIFO topics, encryption, topic policies,
    subscriptions, tags, and data protection policies.

  RESOURCES:
    - aws_sns_topic.this: Creates the SNS topic with configurable attributes.
    - aws_sns_topic_policy.this: Optionally attaches a policy to the topic.
    - aws_sns_topic_subscription.this: Manages subscriptions for the topic.
    - aws_sns_topic_data_protection_policy.this: Optionally attaches a data
        protection policy.
----------------------------------------------------------------------------- */

resource "aws_sns_topic" "this" {
  name                        = var.name
  display_name                = var.display_name
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  kms_master_key_id           = var.kms_master_key_id
  tags                        = var.tags
}

resource "aws_sns_topic_policy" "this" {
  count  = var.create_topic_policy ? 1 : 0
  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy != null ? var.topic_policy : file(var.topic_policy_file_path)
}

resource "aws_sns_topic_subscription" "this" {
  count                  = length(var.subscriptions)
  topic_arn              = aws_sns_topic.this.arn
  protocol               = var.subscriptions[count.index].protocol
  endpoint               = var.subscriptions[count.index].endpoint
  endpoint_auto_confirms = var.subscriptions[count.index].endpoint_auto_confirms
  raw_message_delivery   = var.subscriptions[count.index].raw_message_delivery
}

resource "aws_sns_topic_data_protection_policy" "this" {
  count  = var.create_data_protection_policy ? 1 : 0
  arn    = aws_sns_topic.this.arn
  policy = var.data_protection_policy != null ? var.data_protection_policy : file(var.data_protection_policy_file_path)
}
