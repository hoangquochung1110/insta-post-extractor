variable "functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    # Allow custom function name or use key as name
    function_name = optional(string)  # If not provided, will use the map key

    # Function-specific attributes
    handler     = string
    runtime     = string
    memory_size = optional(number, 128)
    timeout     = optional(number, 30)
    environment_variables = optional(map(string), {})
    description = optional(string, "")
    s3_bucket = string
    s3_key = string
    publish = optional(bool, false)

    # Aliases configuration
    aliases = optional(map(object({
      description     = optional(string)
      function_version = optional(string, "$LATEST")
      routing_config  = optional(object({
        additional_version_weights = optional(map(number))
      }))
    })), {})
  }))
}


variable "execution_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "permission_principal" {
  description = "Who's allowed to invoke (e.g. API Gateway)"
  type        = string
  default     = "apigateway.amazonaws.com"
}
  
variable "source_arn" {
  description = "Resource ARN pattern that's allowed (e.g. API Gateway execute-api ARN)"
  type        = string
  default = "arn:aws:execute-api:ap-southeast-1:838835070561:59vejac25d/*/*/*"
}