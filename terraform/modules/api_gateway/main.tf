// allow fetching account ID for execution ARN pattern
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Post method at root resource (level)
resource "aws_api_gateway_method" "root_post" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_rest_api.this.root_resource_id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "root_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_rest_api.this.root_resource_id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_alias_arn}/invocations"

}


resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.this.id


  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.root_post_integration.id))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.environment
  variables = {
    lambda_alias = var.environment
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = var.api_key_name
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = "${var.environment} Usage Plan"
  description = "Usage Plan for api gatewayt"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
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


resource "aws_api_gateway_usage_plan_key" "api_key_attachment" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
