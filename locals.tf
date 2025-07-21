/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    This file declares local variables for the aws/lambda-layer Terraform module.
    These locals are used to define paths and structures for layer creation,
    including the source code directory and the structure of layer information.

  LOCALS:
    - layers_mount_point:
        The directory where layers will be built. This is a temporary directory
        used during the layer creation process. If this value is set to an empty
        string, the module will use a default path based on the root of the
        Terraform project.
----------------------------------------------------------------------------- */

locals {
  # Mount point dir where layers will be built
  layers_mount_point = var.layers_mount_point == "" ? "${path.root}/.layer_build" : var.layers_mount_point
}
