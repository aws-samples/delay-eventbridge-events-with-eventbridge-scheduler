module "scheduler_dynamodb_table" {
  source                = "./modules/dynamodb-table"
  table_name            = var.dynamodb_table_name
  dynamo_billing_mode   = var.dynamo_billing_mode
  dynamo_read_capacity  = var.dynamo_read_capacity
  dynamo_write_capacity = var.dynamo_write_capacity
}

module "dynamodb_table_stream_lambda" {
  source                       = "./modules/dynamodb-table-stream-lambda"
  dynamodb_table_name          = module.scheduler_dynamodb_table.dynamodb_table_name
  dynamodb_table_arn           = module.scheduler_dynamodb_table.dynamodb_table_arn
  dynamodb_table_stream_arn    = module.scheduler_dynamodb_table.stream_arn
  schedule_handler_lambda_name = module.expire_item.handler_name
  schedule_handler_lambda_arn  = module.expire_item.handler_arn
  lambda_kms_key_arn           = data.aws_kms_key.lambda_kms_key.arn
  sqs_kms_key_arn              = data.aws_kms_key.sqs_kms_key.arn
}

module "expire_item" {
  source                     = "./modules/expire-item"
  schedule_group_name        = var.schedule_group_name
  dynamodb_stream_lambda_arn = module.dynamodb_table_stream_lambda.arn
  dynamodb_table_arn         = module.scheduler_dynamodb_table.dynamodb_table_arn
  dynamodb_table_name        = module.scheduler_dynamodb_table.dynamodb_table_name
  dynamodb_kms_arn           = data.aws_kms_key.dynamodb_kms_key.arn
  lambda_kms_key_arn         = data.aws_kms_key.lambda_kms_key.arn
  sqs_kms_key_arn            = data.aws_kms_key.sqs_kms_key.arn
}
