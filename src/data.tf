# =======================================
# KMS Keys
# =======================================
data "aws_kms_key" "dynamodb_kms_key" {
  key_id = "alias/${var.dynamodb_kms_alias}"
}

data "aws_kms_key" "lambda_kms_key" {
  key_id = "alias/${var.lambda_kms_alias}"
}

data "aws_kms_key" "sqs_kms_key" {
  key_id = "alias/${var.sqs_kms_alias}"
}
