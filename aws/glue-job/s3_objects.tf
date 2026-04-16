/* -----------------------------------------------------------------------------
  FILE: s3_objects.tf
  MODULE: aws/glue-job

  DESCRIPTION:
    This Terraform module provisions AWS Glue Jobs with flexible
    configuration and best practices.

  RESOURCES:
    - aws_lambda_function.this:
        Provisions the Lambda function.
----------------------------------------------------------------------------- */

resource "aws_s3_object" "glue_assets" {
  for_each = { for file in local.glue_assets : file => file }

  bucket = var.glue_assets_s3_bucket_name
  key    = "${var.glue_assets_s3_key_prefix}/${each.value}"
  source = "${path.root}/${each.value}"

  etag = filemd5("${path.root}/${each.value}")
}
