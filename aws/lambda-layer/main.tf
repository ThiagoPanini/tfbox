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
  for_each = { for layer in var.layers_config : layer.name => layer }

  # Defining triggers to ensure the resource is recreated when layer configurations change
  triggers = {
    python_requirements_hash = sha1(join(",", each.value.requirements))
    runtime                  = each.value.runtime[0] # Assuming single runtime for simplicity
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

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    null_resource.build_layer
  ]
}

# Cleaning up temporary build directories and zip files after layer creation if cleanup is enabled
resource "null_resource" "cleanup_layer_build" {
  for_each = { for layer in var.layers_config : layer.name => layer }

  provisioner "local-exec" {
    command     = "rm -rf ${local.layers_mount_point}"
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    aws_lambda_layer_version.this
  ]
}
