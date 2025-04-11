resource "aws_api_gateway_rest_api" "main" {
  name        = "IgPostExtractorGateway"
  description = "Serverless backend for Ig post extractor"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Post method at root resource (level)
resource "aws_api_gateway_method" "post_root" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_rest_api.main.root_resource_id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "root_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_rest_api.main.root_resource_id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-southeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-southeast-1:838835070561:function:${aws_lambda_function.function.function_name}:$${stageVariables.lambda_alias}/invocations"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [aws_cloudwatch_log_group.api_gw_log_group]

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.root_post_integration.id))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.env
  variables = {
    lambda_alias = var.env
  }
}



resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = "${var.env} Usage Plan"
  description = "Usage Plan for api gatewayt"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    # TODO: change to stage resource reference
    stage = aws_api_gateway_stage.stage.stage_name
  }

  quota_settings {
    limit  = 20
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_api_key" "jyd5db5qrh" {
  name = "jyd5db5qrh"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key_attachment" {
  key_id        = aws_api_gateway_api_key.jyd5db5qrh.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}