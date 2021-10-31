data "archive_file" "code" {
  output_path = "${path.module}/builds/code.zip"
  source_dir  = "${path.module}/code"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

data aws_dynamodb_table table {
  name = var.table_name
}

resource "aws_lambda_function" "lambda" {

  function_name    = "sync-ddb-table-${var.table_name}-to-dev"
  role             = aws_iam_role.ddb-stream-lambda-executor.arn
  description      = "Reads off DynamoDB stream and writes the item to the dev environment"
  handler          = "main.lambda_handler"
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  runtime          = "python3.8"

  environment {
    variables = {
      TARGET_AWS_ACCOUNT_NUMBER = var.target_account
      TARGET_ROLE_NAME          = "ProductionDynamoDBSyncRole"
      TARGET_DYNAMODB_NAME      = var.table_name
    }
  }

}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = data.aws_dynamodb_table.table.stream_arn
  function_name     = aws_lambda_function.lambda.arn
  starting_position = "LATEST"
}
