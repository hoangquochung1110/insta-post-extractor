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
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_lambda_alias" "dev" {
  name             = "dev"
  description      = "Dev alias pointing to $LATEST"
  function_name    = aws_lambda_function.function.arn
  function_version = "$LATEST"
}

# Gives an external source (like an EventBridge Rule, SNS, or S3) permission to access the Lambda function.
# aka Resource Policy
resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  # to specify function version or alias name.
  # means this permission applies to dev alias only
  qualifier = "dev"

  # execution_arn/stage/method/resource
  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*/*"
}
