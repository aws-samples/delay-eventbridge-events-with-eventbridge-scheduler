variable "table_name" {
  description = "Table name with any suffixes"
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
