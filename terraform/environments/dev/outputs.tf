output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value       = module.lambda.function_arns
}

output "lambda_alias_arns" {
  description = "ARNs of the Lambda aliases"
  value       = module.lambda.alias_arns
}

output "api_invoke_url" {
  description = "Base URL for the API Gateway"
  value       = module.api_gateway.api_invoke_url
}

output "api_key" {
  description = "API Gateway key"
  value       = module.api_gateway.api_key
  sensitive   = true
}

output "api_execution_arn_pattern" {
  description = "Wildcard ARN pattern for API Gateway executions"
  value       = module.api_gateway.api_execution_arn_pattern
}

output "execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam.execution_role_arn
}