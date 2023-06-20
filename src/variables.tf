###############
# KMS Aliases
###############
variable "dynamodb_kms_alias" {
  description = "KMS alias for DyanmoDB service use"
  type        = string
}

variable "lambda_kms_alias" {
  type        = string
  description = "KMS alias for AWS Lambda service use"
}

variable "sqs_kms_alias" {
  description = "KMS alias for AWS SQS service use"
  type        = string
}

##############################
# Appointments DynamoDB Table
##############################
variable "dynamodb_table_name" {
  description = "DyanmoDB table name"
  type        = string
}

variable "dynamo_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
}

variable "dynamo_read_capacity" {
  description = "Number of read units for this table"
  type        = number
}

variable "dynamo_write_capacity" {
  description = "Number of write units for this table"
  type        = number
}

#####################################
# Schedule Group Name
#####################################

variable "schedule_group_name" {
  type        = string
  description = "The name of the EventBridge Schedule group that all of the schedules will be under"
}
