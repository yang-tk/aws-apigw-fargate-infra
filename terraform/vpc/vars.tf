variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "app_name" {
  type = string
  description = "Application name"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block range for vpc"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "CIDR block range for the private subnets"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
  description = "CIDR block range for the public subnets"
}

variable "stage" {
  type        = string
  description = "Application stage"
}

variable "app_port" {
  type        = string
  description = "app port"
}

variable "region" {
  type        = string
  description = "The AWS region where resources have been deployed"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the selected region"
}
