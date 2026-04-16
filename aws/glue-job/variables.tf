/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/glue-job

  DESCRIPTION:
    
----------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
  VARIABLES: Glue Assets
  Configurations related to the S3 storage and local file paths of Glue
  application scripts.
----------------------------------------------------------------------------- */

variable "glue_assets_s3_bucket_name" {
  description = "The name of the S3 bucket where application scripts are stored."
  type        = string
}

variable "glue_assets_s3_key_prefix" {
  description = "The S3 key prefix (folder path) within the bucket for application scripts."
  type        = string
  default     = "glue-scripts"
}

variable "glue_assets_local_application_folder" {
  description = "The local file path to the application folder containing Glue scripts."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z]+$", var.glue_assets_local_application_folder))
    error_message = "The local application folder value has special characters. Only a-z, A-Z and 0-9 characters are allowed."
  }
}

variable "file_extensions_to_upload" {
  description = "List of file extensions in the application folder that should be uploaded to S3."
  type        = list(string)
  default = [
    ".py",
    ".sql",
    ".json",
    ".txt"
  ]
}

variable "main_script_local_path" {
  description = "The local file path to the main application script that holds the ETL logic."
  type        = string
}
