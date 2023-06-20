variable "dynamodb_table_name" {
  description = "Arn of DynamoDB table stream"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "Arn of DynamoDB table"
  type        = string
}

variable "dynamodb_table_stream_arn" {
  description = "Arn of DynamoDB table stream"
  type        = string
}

variable "schedule_handler_lambda_name" {
  description = "Name of Schedule Handler Lambda"
  type        = string
}

variable "schedule_handler_lambda_arn" {
  description = "Arn of Schedule Handler Lambda"
  type        = string
}

variable "lambda_kms_key_arn" {
  description = "KMS alias for AWS Lambda service use"
  type        = string
}

variable "sqs_kms_key_arn" {
  description = "KMS alias for AWS SQS service use"
  type        = string
}