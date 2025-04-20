output "api_invoke_url" {
  description = "Base URL for API Gateway stage"
  value       = "${aws_api_gateway_stage.stage.invoke_url}${aws_api_gateway_stage.stage.stage_name}"
}

output "api_key" {
  description = "API Gateway usage plan key"
  value       = aws_api_gateway_api_key.api_key.value
  sensitive   = true
}

output "api_execution_arn_pattern" {
  description = "Wildcard ARN pattern for API Gateway executions"
  value       = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*"
}
