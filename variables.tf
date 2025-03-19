variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "app_version" {
  description = "Application version for the S3 key path"
  type        = string
}

variable "function_version" {
  description = "Lambda function version"
  type        = string
}