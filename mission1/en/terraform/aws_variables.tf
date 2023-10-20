/*
 * Terraform variable declarations for AWS.
 */

variable "aws_credentials_file_path" {
  description = "Locate the AWS credentials file."
  type        = string
}

variable "aws_region" {
  description = "Default to EU North 1 region."
  default     = "eu-north-1"
}