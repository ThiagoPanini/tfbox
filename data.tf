/* --------------------------------------------------------
FILE: data.tf

File created to centralize all Terraform data source 
definitions designed to facilitate the declaration and 
configuration of resources throughout the module
-------------------------------------------------------- */

# Defining data sources for collecting account ID and region name
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
