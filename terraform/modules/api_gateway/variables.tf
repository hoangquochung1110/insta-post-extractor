variable "api_name" {
  type = string
}

variable "api_description" {
  type = string
}

variable "api_key_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_alias_arn" {
  description = "ARN of the Lambda alias to integrate"
  type        = string
}

variable "aws_region" {
  type = string
  default = "ap-southeast-1"
}