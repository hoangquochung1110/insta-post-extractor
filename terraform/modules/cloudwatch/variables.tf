variable "name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda functions that need log groups"
  type = map(object({
    function_name = string
  }))
  default = {}
}

variable "retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to assign to the log group"
  type        = map(string)
  default     = {}
}
