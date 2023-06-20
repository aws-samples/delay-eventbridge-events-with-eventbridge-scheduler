variable "schedule_group_name" {
  type        = string
  description = "The name of the EventBridge Schedule group"
}

variable "dynamodb_stream_lambda_arn" {
  type        = string
  description = "The arn of the DynamoDB Stream Lambda handler"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "The arn of the DynamoDB table"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table name."
}

variable "dynamodb_kms_arn" {
  type        = string
  description = "The arn of the DynamoDB table KMS key"
}

variable "lambda_kms_key_arn" {
  type        = string
  description = "KMS alias for AWS Lambda service use"
}

variable "sqs_kms_key_arn" {
  type        = string
  description = "KMS alias for AWS SQS service use"
}