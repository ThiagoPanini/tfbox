/* -----------------------------------------------------------------------------
  FILE: lambda_event_trigger.tf
  MODULE: aws/lambda-function

  DESCRIPTION:
    This file contains the configuration for an EventBridge trigger for a Lambda
    function.

  RESOURCES:
    - aws_cloudwatch_event_rule:
        Creates an EventBridge rule to trigger the Lambda function.

    - aws_lambda_permission: 
        Grants EventBridge permission to invoke the Lambda function.

    - aws_cloudwatch_event_target:
        Associates the EventBridge rule with the Lambda function.
----------------------------------------------------------------------------- */

# Create an EventBridge rule to trigger the Lambda function
resource "aws_cloudwatch_event_rule" "lambda_event_rule" {
  count               = var.create_eventbridge_trigger ? 1 : 0
  name                = "trigger-${var.function_name}"
  description         = "EventBridge rule to trigger Lambda function ${var.function_name}"
  schedule_expression = var.cron_expression

  tags = var.tags

  depends_on = [
    aws_lambda_function.this
  ]
}

# Setting lambda permissions to allow EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "eventbridge_invoke" {
  count         = var.create_eventbridge_trigger ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_event_rule[0].arn

  depends_on = [
    aws_cloudwatch_event_rule.lambda_event_rule
  ]
}

# Associate the EventBridge rule with the Lambda function
resource "aws_cloudwatch_event_target" "lambda_event_target" {
  count = var.create_eventbridge_trigger ? 1 : 0
  rule  = aws_cloudwatch_event_rule.lambda_event_rule[0].name
  arn   = aws_lambda_function.this.arn

  depends_on = [
    aws_lambda_permission.eventbridge_invoke
  ]
}
