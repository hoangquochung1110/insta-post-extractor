resource "aws_api_gateway_rest_api" "IgPostExtractorGateway" {
  name        = "IgPostExtractorGateway"
  description = "Serverless backend for Ig post extractor"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.IgPostExtractorGateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.IgPostExtractorGateway.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.IgPostExtractorGateway.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.IgPostExtractor.invoke_arn}"
}

resource "aws_api_gateway_deployment" "dev" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.IgPostExtractorGateway.id}"
  stage_name  = "dev"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.dev.invoke_url}"
}
