/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    This Terraform module creates AWS Lambda layers based on the provided
    configuration. It builds the layers from specified Python requirements,
    packages them into zip files, and deploys them as Lambda layer versions.
    The module supports cleanup of temporary build directories after layer creation.

  RESOURCES:
    - null_resource.build_layer:
      Builds the layer by installing Python packages into a specified directory.
    
    - data.archive_file.layer_zip:
      Creates a zip archive of the built layer directory.
    
    - aws_lambda_layer_version.this:
      Deploys the zipped layer as a Lambda layer version.
    
    - null_resource.cleanup_layer_build:
      Cleans up temporary build directories and zip files after the layer is
      created, if the cleanup option is enabled.
----------------------------------------------------------------------------- */

# Declaring a null resource to build layers during module call
resource "null_resource" "build_layer" {
  for_each = var.layers_info

  # Defining triggers to ensure the resource is recreated when layer configurations change
  triggers = {
    python_requirements_hash = sha1(join(",", each.value.python_requirements))
    runtime                  = each.value.runtime
  }

  # Using a local-exec provisioner to run commands for building the layer
  provisioner "local-exec" {
    command     = <<-EOT
      # Ensuring the script fails on any error and treats unset variables as errors
      set -euo pipefail
      WORK="${local.layers_mount_point}/${each.key}"
      rm -rf "$WORK"
      mkdir -p "$WORK/python"

      # Creating a temporary requirements.txt file from the provided Python requirements
      printf "%s\n" ${join(" ", each.value.python_requirements)} > "$WORK/req.txt"

      # Upgrading pip and installing the Python packages into the layer's directory
      python -m pip install --upgrade pip
      pip install -r "$WORK/req.txt" --target "$WORK/python"

      # Ensuring determinism by removing cache files
      find "$WORK/python" -type f -name '*.pyc' -delete
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# Creating an archive file for the layer
data "archive_file" "layer_zip" {
  for_each    = null_resource.build_layer
  type        = "zip"
  source_dir  = "${local.layers_mount_point}/${each.key}"
  output_path = "${local.layers_mount_point}/${each.key}.zip"

  depends_on = [
    null_resource.build_layer
  ]
}

# Creating the AWS Lambda layer version from the zipped archive
resource "aws_lambda_layer_version" "this" {
  for_each = data.archive_file.layer_zip

  filename                 = each.value.output_path
  layer_name               = each.key
  description              = lookup(var.layers_info[each.key], "description", null)
  compatible_runtimes      = [var.layers_info[each.key].runtime]
  compatible_architectures = lookup(var.layers_info[each.key], "compatible_architectures", null)

  # Ensuring the layer is created before destroying the old version to avoid downtime
  lifecycle {
    create_before_destroy = true
  }
}

# Cleaning up temporary build directories and zip files after layer creation if cleanup is enabled
resource "null_resource" "cleanup_layer_build" {
  for_each = var.cleanup_after_build ? aws_lambda_layer_version.this : {}

  # Local-exec provisioner to remove temporary build directory and zip file
  provisioner "local-exec" {
    command     = "rm -rf ${local.layers_mount_point}/${each.key} ${local.layers_mount_point}/${each.key}.zip"
    interpreter = ["/bin/bash", "-c"]
  }

  # This makes the resource run every time Terraform applies
  triggers = {
    always_run = timestamp()
  }

  # Ensure cleanup only happens after the layer is created
  depends_on = [
    aws_lambda_layer_version.this
  ]
}

