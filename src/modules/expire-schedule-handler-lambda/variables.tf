variable "schedule_group_name" {
  type        = string
  description = "The name of the EventBridge Schedule group"
}

variable "schedule_role_arn" {
  type        = string
  description = "The arn of the EventBridge Schedule IAM role"
}

variable "dynamodb_stream_lambda_arn" {
  type        = string
  description = "The arn of the DynamoDB Stream Lambda handler"
}

variable "schedule_target_lambda_arn" {
  type        = string
  description = "Arn of Schedule Target Lambda"
}

variable "lambda_kms_key_arn" {
  type        = string
  description = "KMS alias for AWS Lambda service use"
}

variable "sqs_kms_key_arn" {
  type        = string
  description = "KMS alias for AWS SQS service use"
}