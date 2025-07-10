/* --------------------------------------------------------
FILE: main.tf @ aws/lambda-layer module

Definition and application of necessary rules for creation
and deployment of layers (and layer versions) for Lambda 
functions on AWS
-------------------------------------------------------- */

/*
resource "aws_lambda_layer_version" "this" {
  layer_name  = var.layer_name
  description = var.layer_description

  compatible_architectures = var.layer_compatible_architectures
  compatible_runtimes      = var.layer_compatible_runtimes

  license_info = var.layer_license_info

  filename = var.layer_zip_filepath

  s3_bucket         = var.layer_s3_bucket
  s3_key            = var.layer_s3_object_key
  s3_object_version = var.layer_s3_object_version
}
*/

/*
resource "aws_lambda_layer_version" "this" {
  for_each   = local.layers_info
  layer_name = each.value.layer_name
  filename   = each.value.layer_filename
}
*/

# Instantiated only if var.flag_create_from_dir=true and var.flag_create_from_input=false
resource "aws_lambda_layer_version" "from_dir" {
  for_each                 = local.layers_info
  layer_name               = each.value.layer_name
  filename                 = each.value.filename
  description              = each.value.description
  compatible_runtimes      = each.value.compatible_runtimes
  compatible_architectures = each.value.compatible_architectures
  license_info             = each.value.license_info
}


/*
ToDo:
  - Test logic for creating layers through map provided by user

*/
