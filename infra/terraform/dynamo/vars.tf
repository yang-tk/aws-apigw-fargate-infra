variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "table_name" {
  type = string
  description = "DynamoDB table name"
}
