resource "aws_sqs_queue" "dlq" {
  name       = "expire-schedule-target-dlq"
  fifo_queue = false

  visibility_timeout_seconds = 930
  message_retention_seconds  = 1209600
  max_message_size           = 262144
  delay_seconds              = 0
  receive_wait_time_seconds  = 0

  kms_master_key_id                 = var.sqs_kms_key_arn
  kms_data_key_reuse_period_seconds = 900

}

resource "aws_iam_role" "iam_for_lambda" {
  name                = "iam_for_expiration_lambda_target"
  assume_role_policy  = data.aws_iam_policy_document.policy.json
  managed_policy_arns = [aws_iam_policy.policy.arn, "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_iam_policy" "policy" {
  name = "AppointmentTableEditPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
        Effect   = "Allow"
        Resource = ["${var.dynamodb_table_arn}"]
      },
      {
        Action   = ["kms:Decrypt"]
        Effect   = "Allow"
        Resource = ["${var.dynamodb_table_kms_arn}"]
      },
      {
        Action   = ["scheduler:DeleteSchedule"]
        Effect   = "Allow"
        Resource = ["arn:aws:scheduler:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:schedule/${var.schedule_group_name}/*"]
      },
      {
        Action   = ["sqs:SendMessage"]
        Effect   = "Allow"
        Resource = ["${aws_sqs_queue.dlq.arn}"]
      }
    ]
  })
}

resource "aws_lambda_function" "lambda" {
  # checkov:skip=CKV_AWS_272:Code is trusted
  # checkov:skip=CKV_AWS_117:No need for VPC
  function_name = "expire-schedule-target-lambda"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role    = aws_iam_role.iam_for_lambda.arn
  handler = "expire-schedule-target-lambda.handler"
  runtime = "python3.9"

  environment {
    variables = {
      DYNAMO_TABLE_NAME = var.dynamodb_table_name
      SHEDULE_GROUP     = var.schedule_group_name
    }
  }

  kms_key_arn = var.lambda_kms_key_arn
  tracing_config {
    mode = "Active"
  }
  reserved_concurrent_executions = -1

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

}