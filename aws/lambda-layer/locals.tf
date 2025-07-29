/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    Local values for the Lambda layer module.
----------------------------------------------------------------------------- */

locals {
  # Mount point dir where layers will be built
  layers_mount_point = var.layers_mount_point == "" ? "${path.root}/.layer_build" : var.layers_mount_point
}
