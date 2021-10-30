data "archive_file" "replay-stream" {
  output_path = "${path.module}/builds/replay-stream.zip"
  source_dir  = "${path.module}/functions/replay-stream"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

resource "aws_lambda_function" "sync-assets-to-dev" {

  function_name    = "sync-ddb-table-assets-to-dev"
  role             = aws_iam_role.ddb-stream-lambda-executor.arn
  description      = "Reads off DynamoDB stream and writes the item to the dev environment"
  handler          = "lambda_handler.lambda_handler"
  filename         = data.archive_file.replay-stream.output_path
  source_code_hash = data.archive_file.replay-stream.output_base64sha256
  runtime          = "python3.8"

  environment {
    variables = {
      TARGET_AWS_ACCOUNT_NUMBER = var.dev_account_id
      TARGET_ROLE_NAME          = "arn:aws:iam::${var.dev_account_id}:role/ProductionDynamoDBSyncRole"
      TARGET_DYNAMODB_NAME      = aws_dynamodb_table.assets.name
      TARGET_REGION             = data.aws_region.current.name  
    }
  }

  tags = {
    TableName = aws_dynamodb_table.assets.name
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_dynamodb_table.assets.stream_arn
  function_name     = aws_lambda_function.sync-assets-to-dev.arn
  starting_position = "LATEST"
}
