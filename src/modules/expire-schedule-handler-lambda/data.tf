data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/expire-schedule-handler-lambda.zip"
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

# =======================================
# AWS Account ID
# =======================================
data "aws_caller_identity" "current" {}

# =======================================
# AWS Regions
# =======================================
data "aws_region" "current" {}