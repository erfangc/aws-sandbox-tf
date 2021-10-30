data "aws_elasticsearch_domain" "esd" {
  domain_name = var.elasticsearch_domain
}

data "archive_file" "lambda" {
  output_path = "${path.module}/builds/lambda.zip"
  source_dir  = "${path.module}/lambda"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

resource "aws_lambda_function" "lambda" {

  function_name    = "sync-${var.name}-from-ddb-to-es"
  role             = aws_iam_role.lambda-executor.arn
  description      = "Reads off DynamoDB stream for table ${var.name} and sync to Elasticsearch"
  handler          = "lambda_handler.lambda_handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.8"

  vpc_config {
    security_group_ids = [var.security_group_id]
    subnet_ids         = var.subnet_ids
  }

  environment {
    variables = {
      ES_ENDPOINT = data.aws_elasticsearch_domain.esd.endpoint
    }
  }

  tags = {
    TableName = aws_dynamodb_table.table.name
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_dynamodb_table.table.stream_arn
  function_name     = aws_lambda_function.lambda.arn
  starting_position = "LATEST"
}
