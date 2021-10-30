resource "aws_iam_role" "lambda-executor" {
  name               = "${var.name}-DynamoSearchStackLambdaExecutionRole"
  assume_role_policy = jsonencode(
  {
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect    = "Allow",
        Sid       = "LambdaAssumeRole"
      }
    ]
  }
  )
}

resource "aws_iam_policy" "ddb-stream-lambda-executor-policy" {
  name   = "${var.name}-DynamoSearchStackLambdaExecutionPolicy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = ["logs:*"]
        Effect   = "Allow",
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      },
      {
        Action   = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:GetRecords",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ddb-stream-lambda-executor-policy-attachment" {
  name       = "${var.name}-DynamoSearchStackLambdaExecutionAttachment"
  policy_arn = aws_iam_policy.ddb-stream-lambda-executor-policy.arn
  roles      = [aws_iam_role.lambda-executor.name]
}