resource "aws_scheduler_schedule_group" "expiration_schedule_group" {
  name = var.schedule_group_name
}

resource "aws_iam_role" "expiration_schedule_role" {
  name                = "ExpirationScheduleRole"
  assume_role_policy  = data.aws_iam_policy_document.schedule_policy.json
  managed_policy_arns = [aws_iam_policy.invoke_schedule_target_policy.arn]
}

resource "aws_iam_policy" "invoke_schedule_target_policy" {
  name = "invoke_schedule_target_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"]
        Effect   = "Allow"
        Resource = ["${module.expire_schedule_target_lambda.arn}"]
      },
    ]
  })
}

module "expire_schedule_handler_lambda" {
  source                     = "../expire-schedule-handler-lambda"
  schedule_group_name        = var.schedule_group_name
  schedule_role_arn          = aws_iam_role.expiration_schedule_role.arn
  dynamodb_stream_lambda_arn = var.dynamodb_stream_lambda_arn
  schedule_target_lambda_arn = module.expire_schedule_target_lambda.arn
  lambda_kms_key_arn         = var.lambda_kms_key_arn
  sqs_kms_key_arn            = var.sqs_kms_key_arn
}

module "expire_schedule_target_lambda" {
  source                 = "../expire-schedule-target-lambda"
  dynamodb_table_arn     = var.dynamodb_table_arn
  dynamodb_table_name    = var.dynamodb_table_name
  dynamodb_table_kms_arn = var.dynamodb_kms_arn
  schedule_group_name    = var.schedule_group_name
  lambda_kms_key_arn     = var.lambda_kms_key_arn
  sqs_kms_key_arn        = var.sqs_kms_key_arn
}

