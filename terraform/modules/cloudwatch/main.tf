# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage
resource "aws_cloudwatch_log_group" "api_gw_log_group" {
  name              = var.name
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

# Create log groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_log_groups" {
  for_each = var.lambda_functions

  name              = "/aws/lambda/${each.value.function_name}"
  retention_in_days = var.retention_in_days
  tags              = var.tags
}
