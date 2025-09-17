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
        used during the layer creation process.
    
    - layer_config_hashes:
        A map of layer names to their configuration hashes for detecting changes.
----------------------------------------------------------------------------- */

locals {
  # Mount point dir where layers will be built
  layers_mount_point = "${path.root}/.layer_build"

  # Create a map of layer names to their configuration hashes
  # This allows us to detect changes in layer configuration
  layer_config_hashes = {
    for layer in var.layers_config : layer.name => md5(join("|", [
      join(",", layer.requirements),
      join(",", layer.runtime),
      join(",", layer.compatible_architectures),
      layer.description
    ]))
  }
}
