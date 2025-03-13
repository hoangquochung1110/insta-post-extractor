output "aws_api_gateway_rest_api_info" {
  value = {
    id               = aws_api_gateway_rest_api.main.id
    arn              = aws_api_gateway_rest_api.main.arn
    execution_arn    = aws_api_gateway_rest_api.main.execution_arn
    root_resource_id = aws_api_gateway_rest_api.main.root_resource_id
  }
}

output "lambda_func_alias_dev" {
  value = {
    invoke_arn = aws_lambda_alias.dev.invoke_arn
    arn        = aws_lambda_alias.dev.arn
  }
}
