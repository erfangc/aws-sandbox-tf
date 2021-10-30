module "sync-assets-to-dev" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "sync-ddb-table-assets-to-dev"
  description   = "Reads off DynamoDB stream and writes the item to the dev environment"
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.8"

  source_path = "./functions/replay-stream"

  event_source_mapping = {
    dynamodb = {
      event_source_arn  = aws_dynamodb_table.assets.stream_arn
      starting_position = "LATEST"
    }
  }

  allowed_triggers = {
    dynamodb = {
      principal  = "dynamodb.amazonaws.com"
      source_arn = aws_dynamodb_table.assets.stream_arn
    }
  }

  environment_variables = {
    TARGET_AWS_ACCOUNT_NUMBER = var.dev_account_id
    TARGET_ROLE_NAME          = "arn:aws:iam::${var.dev_account_id}:role/ProductionDynamoDBSyncRole"
    TARGET_DYNAMODB_NAME      = aws_dynamodb_table.assets.name
    TARGET_REGION             = data.aws_region.current.name
  }

  tags = {
    TableName = aws_dynamodb_table.assets.name
  }
}
