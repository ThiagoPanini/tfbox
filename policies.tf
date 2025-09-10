/* -----------------------------------------------------------------------------
  FILE: policies.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    This Terraform file manages the declaration, rendering, and deployment of
    IAM policies to be associated with an IAM role. It automates the process of
    rendering user-defined policy templates, loading the rendered files, and
    creating AWS IAM policies from them.

  RESOURCES:
    - template_dir.policies_templates:
      Renders IAM policy templates from a source directory using provided
      variables, outputting them to a destination directory.

    - data.local_file.policies_files:
      Loads the rendered policy files as local data sources, enabling their
      contents to be used in subsequent resources.

    - aws_iam_policy.policies:
      Creates AWS IAM policies for each rendered template file, using the
      loaded file content as the policy document.
----------------------------------------------------------------------------- */

# Render IAM policy templates using user-defined variables
resource "template_dir" "policies_templates" {
  source_dir      = var.policies_template_config.templates_source_dir
  destination_dir = local.templates_destination_dir
  vars            = var.policies_template_config.templates_vars
}

# Load rendered policy files as local data sources
data "local_file" "policies_files" {
  for_each = local.templates_filepaths
  filename = each.value

  depends_on = [
    template_dir.policies_templates
  ]
}

# Create AWS IAM policies from each rendered template file
resource "aws_iam_policy" "policies" {
  for_each = data.local_file.policies_files
  name     = each.key
  policy   = each.value.content

  depends_on = [
    template_dir.policies_templates,
    data.local_file.policies_files
  ]
}
