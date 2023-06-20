data "aws_iam_policy_document" "schedule_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["scheduler.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        "${data.aws_caller_identity.current.account_id}"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:scheduler:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:schedule/${var.schedule_group_name}/*"
      ]
    }

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