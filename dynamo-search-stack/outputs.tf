output "name" {
  value       = aws_dynamodb_table.table.name
}

output "hash_key" {
  value       = aws_dynamodb_table.table.hash_key
}

output "range_key" {
  value       = aws_dynamodb_table.table.range_key
}

output "arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.table.arn
}

output "id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.table.id
}

output "stream_arn" {
  description = "The ARN of the Table Stream. Only available when var.stream_enabled is true"
  value       = aws_dynamodb_table.table.stream_arn
}

output "stream_label" {
  description = "A timestamp, in ISO 8601 format of the Table Stream. Only available when var.stream_enabled is true"
  value       = aws_dynamodb_table.table.stream_label
}
