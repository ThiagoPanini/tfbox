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
      Uses MD5 hash triggers to detect changes in layer configuration.
    
    - aws_lambda_layer_version.this:
      Deploys the zipped layer as a Lambda layer version.
      Uses source_code_hash to trigger updates when layer configuration changes.
    
    - null_resource.cleanup_layer_build:
      Safely cleans up layer-specific build directories and zip files after 
      the layer is created. Only removes files that exist and avoids race conditions.
----------------------------------------------------------------------------- */

# Declaring a null resource to build layers during module call
resource "null_resource" "build_layer" {
  for_each = { for layer in var.layers_config : layer.name => layer }

  # Defining triggers to ensure the resource is recreated when layer configurations change
  triggers = {
    layer_config_hash = local.layer_config_hashes[each.value.name]
  }

  # Using a local-exec provisioner to run commands for building the layer
  provisioner "local-exec" {
    command     = <<-EOT
      WORK="${local.layers_mount_point}/${each.value.name}"
      rm -rf "$WORK"
      mkdir -p "$WORK/python"

      # Creating a temporary requirements.txt file from the provided Python requirements
      printf "%s\n" ${join(" ", each.value.requirements)} > "$WORK/req.txt"

      # Upgrading pip and installing the Python packages into the layer's directory
      python -m pip install --upgrade pip
      pip install -r "$WORK/req.txt" --target "$WORK/python"

      # Ensuring determinism by removing cache files
      find "$WORK/python" -type f -name '*.pyc' -delete

      # Zip the python directory for Lambda layer
      if [ -d "$WORK/python" ]; then
        cd "$WORK" && zip -r "../${each.value.name}.zip" python
      else
        echo "No python directory to zip for layer ${each.value.name}"; exit 1
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# Creating the AWS Lambda layer version from the zipped archive
resource "aws_lambda_layer_version" "this" {
  for_each = { for layer in var.layers_config : layer.name => layer }

  filename                 = "${local.layers_mount_point}/${each.value.name}.zip"
  layer_name               = each.value.name
  description              = each.value.description
  license_info             = each.value.license_info
  compatible_runtimes      = each.value.runtime
  compatible_architectures = each.value.compatible_architectures

  # Add source code hash to detect changes in requirements and other layer configuration
  source_code_hash = local.layer_config_hashes[each.value.name]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    null_resource.build_layer
  ]
}

# Cleaning up specific layer build artifacts after layer creation
resource "null_resource" "cleanup_layer_build" {
  for_each = { for layer in var.layers_config : layer.name => layer }

  provisioner "local-exec" {
    command     = <<-EOT
      # Only clean up files that actually exist for this specific layer
      LAYER_DIR="${local.layers_mount_point}/${each.value.name}"
      LAYER_ZIP="${local.layers_mount_point}/${each.value.name}.zip"
      
      # Remove layer-specific directory if it exists
      if [ -d "$LAYER_DIR" ]; then
        echo "Cleaning up layer directory: $LAYER_DIR"
        rm -rf "$LAYER_DIR"
      fi
      
      # Remove layer-specific zip file if it exists
      if [ -f "$LAYER_ZIP" ]; then
        echo "Cleaning up layer zip: $LAYER_ZIP"
        rm -f "$LAYER_ZIP"
      fi
      
      # Clean up mount point only if it's empty (no other layers building)
      if [ -d "${local.layers_mount_point}" ] && [ -z "$(ls -A ${local.layers_mount_point} 2>/dev/null)" ]; then
        echo "Cleaning up empty mount point: ${local.layers_mount_point}"
        rmdir "${local.layers_mount_point}" 2>/dev/null || true
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  # Trigger cleanup only when this specific layer changes, not on every run
  triggers = {
    layer_config_hash = local.layer_config_hashes[each.value.name]
  }

  depends_on = [
    aws_lambda_layer_version.this
  ]
}
