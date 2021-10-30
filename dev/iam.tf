resource "aws_iam_role" "prod-ddb-sync" {
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.prod_account_id}:role/DynamoDBStreamLambdaExecutioner"
        },
        Action    = "sts:AssumeRole"
        Condition = {}
      }
    ]
  })
  name               = "ProductionDynamoDBSyncRole"
  description        = "Allow production account to access DynamoDB in this environment to keep them in sync"
  tags               = {
    Name = "ProductionDynamoDBSyncRole"
    Env  = "prod"
  }
}

resource "aws_iam_policy" "allow-ddb-access" {
  name   = "AllowDynamoDBAccess"
  policy = jsonencode(
  {
    Version   = "2012-10-17",
    Statement = [
      {
        Sid      = "Sid0",
        Effect   = "Allow",
        Action   = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:ListTables",
        ],
        Resource = "*"
      }
    ]
  }
  )
}

resource "aws_iam_policy_attachment" "allow-ddb-access-prod-ddb-sync" {
  name       = "allow-ddb-access-prod-ddb-sync"
  policy_arn = aws_iam_policy.allow-ddb-access.arn
  roles      = [aws_iam_role.prod-ddb-sync.name]
}
