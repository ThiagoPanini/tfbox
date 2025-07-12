/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    This file declares local variables for the aws/iam-role Terraform module.
    These locals centralize dynamic values and computed paths used during
    deployment, such as the output directory for rendered policy templates,
    the list of template filenames, and their destination paths.

  LOCALS:
    - rendered_templates_dir:
        The directory path where rendered policy templates will be output.
        Computed based on the source directory of policy templates.

    - policies_templates_destination_dir:
        The destination directory for policy templates. If not explicitly set,
        defaults to the rendered templates directory.

    - templates_filenames:
        A list of filenames for all policy templates in the source directory,
        filtered to include only files with ".json" or ".tpl" extensions.

    - templates_filepaths:
        A map of template names (without extension) to their full destination
        file paths, used for role creation.
----------------------------------------------------------------------------- */

locals {
  # Output directory for rendered policy templates
  rendered_templates_dir = "${var.policy_templates_source_dir}/../${basename(var.policy_templates_source_dir)}_rendered"

  # Destination directory for policy templates; defaults to rendered_templates_dir if not set
  policies_templates_destination_dir = var.policy_templates_destination_dir == "" ? local.rendered_templates_dir : var.policy_templates_destination_dir

  # List of policy template filenames in the source directory, filtered by ".json" and ".tpl" extensions
  templates_filenames = [
    for file in fileset(var.policy_templates_source_dir, "**") :
    file if lower(element(split(".", file), -1)) == "json" || lower(element(split(".", file), -1)) == "tpl"
  ]

  # Map of template names (without extension) to their full destination file paths
  templates_filepaths = {
    for tpl in local.templates_filenames :
    split(".", tpl)[0] => "${local.policies_templates_destination_dir}/${tpl}"
  }
}
