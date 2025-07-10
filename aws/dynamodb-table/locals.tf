/* --------------------------------------------------------
FILE: locals.tf

File responsible for declaring local variables/values
capable of assisting in obtaining dynamic information
used during project deployment, such as the target 
deployment account ID or region name.
-------------------------------------------------------- */

locals {
  # Extracting account ID and region name
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name
}
