/* --------------------------------------------------------
FILE: policies.tf @ aws/iam module

Definition and management of processes for declaration and
deployment of IAM policies to be linked to the role
created with this module call
-------------------------------------------------------- */

# Rendering policy templates previously defined by the user
resource "template_dir" "policies_templates" {
  source_dir      = var.policy_templates_source_dir
  destination_dir = local.policies_templates_destination_dir
  vars            = var.policy_templates_vars
}

# Obtaining rendered files in data source that represents local files
data "local_file" "policies_files" {
  for_each = local.templates_filepaths
  filename = each.value

  depends_on = [
    template_dir.policies_templates
  ]
}

# Creating IAM policies for each available template
resource "aws_iam_policy" "policies" {
  for_each = data.local_file.policies_files
  name     = each.key
  policy   = each.value.content

  depends_on = [
    template_dir.policies_templates,
    data.local_file.policies_files
  ]
}

