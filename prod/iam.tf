resource "aws_iam_role" "ddb-stream-lambda-executor" {
  name               = "DynamoDBStreamLambdaExecutioner"
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
  name   = "DynamoDBStreamLambdaExecutionerPolicy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = ["logs:*"]
        Effect   = "Allow",
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow",
        Resource = [
          "arn:aws:iam::${var.dev_account_id}:role/ProductionDynamoDBSyncRole"
        ]
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
  name       = "ddb-stream-lambda-executor-policy-attachment"
  policy_arn = aws_iam_policy.ddb-stream-lambda-executor-policy.arn
  roles      = [aws_iam_role.ddb-stream-lambda-executor.name]
}