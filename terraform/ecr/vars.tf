variable "app_name" {
  type = string
  description = "Application name"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}
