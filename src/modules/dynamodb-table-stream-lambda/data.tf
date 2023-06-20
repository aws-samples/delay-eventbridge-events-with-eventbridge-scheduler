data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/dynamodb-table-stream-lambda.zip"
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