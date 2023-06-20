output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.table.name
}

output "dynamodb_table_arn" {
  description = "AWS Arn of the DynamoDB table"
  value       = aws_dynamodb_table.table.arn
}

output "stream_arn" {
  description = "AWS Arn of the DynamoDB table Stream"
  value       = aws_dynamodb_table.table.stream_arn
} 