/* --------------------------------------------------------
FILE: locals.tf @ aws/iam-role module

File responsible for declaring local variables/values
capable of assisting in obtaining dynamic information
used during project deployment, such as the target 
deployment account ID or region name.
-------------------------------------------------------- */

locals {
  # Defining output directory for policy templates
  rendered_templates_dir             = "${var.policy_templates_source_dir}/../${basename(var.policy_templates_source_dir)}_rendered"
  policies_templates_destination_dir = var.policy_templates_destination_dir == "" ? local.rendered_templates_dir : var.policy_templates_destination_dir

  # Obtaining list of all resulting templates filtering only allowed extensions
  templates_filenames = [
    for file in fileset(var.policy_templates_source_dir, "**") :
    file if lower(element(split(".", file), -1)) == "json" || lower(element(split(".", file), -1)) == "tpl"
  ]

  # Building path of all obtained templates for role creation
  templates_filepaths = {
    for tpl in local.templates_filenames :
    split(".", tpl)[0] => "${local.policies_templates_destination_dir}/${tpl}"
  }
}
