resource "aws_dynamodb_table" "table" {
  # checkov:skip=CKV_AWS_119: Currently using AWS's default encryption key
  name           = "${var.table_name}-${data.aws_caller_identity.this.account_id}-${data.aws_region.this.name}"
  billing_mode   = var.dynamo_billing_mode
  read_capacity  = var.dynamo_read_capacity
  write_capacity = var.dynamo_write_capacity

  hash_key = "pk"
  attribute {
    name = "pk"
    type = "S"
  }

  range_key = "sk"
  attribute {
    name = "sk"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled     = true
  }

  point_in_time_recovery {
    enabled = true
  }

}
