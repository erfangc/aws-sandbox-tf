data "archive_file" "code" {
  output_path = "${path.module}/builds/code.zip"
  source_dir  = "${path.module}/code"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

resource "aws_lambda_function" "lambda" {

  function_name    = "sync-${var.name}-from-ddb-to-es"
  role             = aws_iam_role.lambda-executor.arn
  description      = "Reads off DynamoDB stream for table ${var.name} and sync to Elasticsearch"
  handler          = "main.lambda_handler"
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  runtime          = "python3.8"
  timeout          = 3

  vpc_config {
    security_group_ids = [var.vpc_config.security_group_id]
    subnet_ids         = var.vpc_config.subnet_ids
  }

  environment {
    variables = {
      ES_ENDPOINT = var.elasticsearch_domain.endpoint
    }
  }

  tags = {
    TableName = aws_dynamodb_table.table.name
  }
}

resource "aws_lambda_event_source_mapping" "source_mapping" {
  event_source_arn  = aws_dynamodb_table.table.stream_arn
  function_name     = aws_lambda_function.lambda.arn
  starting_position = "LATEST"
}
