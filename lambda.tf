provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_lambda_function" "function" {
  function_name = "IgPostExtractor"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "ig-post-extractor-artifact"
  s3_key    = "${var.app_version}/ig_post_extractor.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "ig_post_extractor.lambda_handler"
  runtime = "python3.12"
  timeout = 30

  role = aws_iam_role.ig_post_extractor_exec_role.arn
}

variable "app_version" {
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "ig_post_extractor_exec_role" {
  name = "ig_post_extractor_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name   = "policy-8675309"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions   = ["bedrock:InvokeModel"]
    resources = ["*"]
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_alias" "dev" {
  name             = "dev"
  description      = "Dev alias pointing to $LATEST"
  function_name    = aws_lambda_function.function.arn
  function_version = "$LATEST"
}
