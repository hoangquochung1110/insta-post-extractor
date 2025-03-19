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

resource "aws_iam_policy" "allow_inference_profile_policy" {
  name = "allow_inference_profile_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:bedrock:ap-southeast-1:838835070561:inference-profile/apac.amazon.nova-micro-v1:0"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_inference_profile_policy_attachment" {
  role       = aws_iam_role.ig_post_extractor_exec_role.id
  policy_arn = aws_iam_policy.allow_inference_profile_policy.arn
}

resource "aws_iam_policy" "allow_bedrock_invocation_policy" {
  name = "allow_bedrock_invocation_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:bedrock:ap-southeast-1::foundation-model/amazon.nova-micro-v1:0",
          "arn:aws:bedrock:ap-southeast-2::foundation-model/amazon.nova-micro-v1:0",
          "arn:aws:bedrock:ap-south-1::foundation-model/amazon.nova-micro-v1:0",
          "arn:aws:bedrock:ap-northeast-2::foundation-model/amazon.nova-micro-v1:0",
          "arn:aws:bedrock:ap-northeast-1::foundation-model/amazon.nova-micro-v1:0",
          "arn:aws:bedrock:ap-northeast-3::foundation-model/amazon.nova-micro-v1:0"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_bedrock_invocation_policy_attachment" {
  role       = aws_iam_role.ig_post_extractor_exec_role.id
  policy_arn = aws_iam_policy.allow_bedrock_invocation_policy.arn
}

resource "aws_lambda_alias" "alias" {
  name             = var.env
  description      = "${var.env} alias"
  function_name    = aws_lambda_function.function.arn
  function_version = var.function_version
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
  qualifier = aws_lambda_alias.alias.name

  # execution_arn/stage/method/resource
  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*/*"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole-attachment" {
  role       = aws_iam_role.ig_post_extractor_exec_role.id
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}