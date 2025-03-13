resource "aws_api_gateway_rest_api" "main" {
  name        = "IgPostExtractorGateway"
  description = "Serverless backend for Ig post extractor"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Post method at root resource (level)
resource "aws_api_gateway_method" "post_root" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method = "POST"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-southeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-southeast-1:838835070561:function:${aws_lambda_function.function.function_name}:$${stageVariables.lambda_alias}/invocations"
}

resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.root_post_integration.id))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.dev.id
  stage_name    = "dev"
  variables = {
    lambda_alias = "${aws_lambda_alias.dev.name}"
  }
}


# Usage plan for dev stage
resource "aws_api_gateway_usage_plan" "dev" {
  name        = "Dev Usage Plan"
  description = "Usage Plan for api gateway in dev stage/environment"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    # TODO: change to stage resource reference
    stage = aws_api_gateway_stage.dev.stage_name
  }

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

