output "api_gw_log_group_arn" {
  description = "ARN of the API Gateway CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gw_log_group.arn
}

output "lambda_log_group_arns" {
  description = "Map of Lambda function names to their CloudWatch log group ARNs"
  value = {
    for key, log_group in aws_cloudwatch_log_group.lambda_log_groups : key => log_group.arn
  }
}
