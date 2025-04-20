# Create the Lambda functions
resource "aws_lambda_function" "functions" {
  for_each = var.functions
  
  # Use either the naming convention or the provided/default name
  function_name = each.value.function_name
  s3_bucket = each.value.s3_bucket
  s3_key = each.value.s3_key
  # Function-specific configuration
  handler          = each.value.handler
  runtime          = each.value.runtime
  memory_size      = each.value.memory_size
  timeout          = each.value.timeout
  publish = each.value.publish

  role = var.execution_role_arn
}

# Create Lambda function aliases
resource "aws_lambda_alias" "function_aliases" {
  for_each = {
    for alias_config in flatten([
      for func_key, func in var.functions : [
        for alias_name, alias in func.aliases : {
          function_key  = func_key
          alias_name    = alias_name
          description   = alias.description
          version       = alias.function_version
          routing_config = alias.routing_config
        }
      ]
    ]) : "${alias_config.function_key}_${alias_config.alias_name}" => alias_config
  }
  
  # Alias configuration
  name             = each.value.alias_name
  description      = each.value.description
  function_name    = aws_lambda_function.functions[each.value.function_key].function_name
  function_version = each.value.version
}

# grant a principal (e.g. API Gateway) permission to invoke each alias
resource "aws_lambda_permission" "alias_invoke" {
  for_each = aws_lambda_alias.function_aliases

  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.function_aliases[each.key].function_name
  qualifier     = aws_lambda_alias.function_aliases[each.key].name

  principal   = var.permission_principal       # e.g. "apigateway.amazonaws.com"
  source_arn  = var.source_arn
}