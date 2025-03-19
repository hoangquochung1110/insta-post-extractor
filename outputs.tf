output "aws_api_gateway_rest_api_info" {
  value = {
    id               = aws_api_gateway_rest_api.main.id
    arn              = aws_api_gateway_rest_api.main.arn
    execution_arn    = aws_api_gateway_rest_api.main.execution_arn
    root_resource_id = aws_api_gateway_rest_api.main.root_resource_id
    dev_stage = {
      invoke_url = aws_api_gateway_stage.stage.invoke_url
    }
  }
}

output "lambda_func_alias_dev" {
  value = {
    invoke_arn = aws_lambda_alias.alias.invoke_arn
    arn        = aws_lambda_alias.alias.arn
  }
}
