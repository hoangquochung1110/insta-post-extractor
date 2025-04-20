# Lambda execution role
resource "aws_iam_role" "exec_role" {
  name = var.execution_role_name
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
  role       = aws_iam_role.exec_role.id
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
  role       = aws_iam_role.exec_role.id
  policy_arn = aws_iam_policy.allow_bedrock_invocation_policy.arn
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole-attachment" {
  role       = aws_iam_role.exec_role.id
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}