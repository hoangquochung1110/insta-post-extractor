resource "aws_api_gateway_rest_api" "main" {
  name        = "IgPostExtractorGateway"
  description = "Serverless backend for Ig post extractor"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Post method at root resource (level)
resource "aws_api_gateway_method" "post_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.main.id}"
  resource_id   = "${aws_api_gateway_rest_api.main.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

// Integration at root level (No resources) for dev environment
resource "aws_api_gateway_integration" "dev_integration_root" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  resource_id = "${aws_api_gateway_method.post_root.resource_id}"
  http_method = "${aws_api_gateway_method.post_root.http_method}"

  integration_http_method = "POST"
  type                    = "HTTP"
  uri                     = "${aws_lambda_alias.dev.invoke_arn}"
}

resource "aws_api_gateway_deployment" "dev_integration_root" {
  depends_on = [
    aws_api_gateway_integration.integration_root,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name  = "dev"
}

resource "aws_api_gateway_usage_plan" "dev" {
  name         = "Dev Usage Plan"
  description  = "Usage Plan for api gateway in dev environment"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_deployment.dev.stage_name
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

data "aws_api_gateway_api_key" "api_key" {
  id = "jyd5db5qrh"
}

output "dev_base_url" {
  value = "${aws_api_gateway_deployment.dev.invoke_url}"
}

output "api_key" {
  value = "${data.aws_api_gateway_api_key.api_key.value}"
  sensitive = true
}
