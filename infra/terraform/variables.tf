variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "aws_assume_role" {
  type        = string
  description = "AWS assume role (for different environment)"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "AWS application environment (dev, qa, prod)"
}

variable "stage" {
  type        = string
  description = "Application stage (dev01, dev02, sandbox, prod01)"
}

variable "app_image" {
  type        = string
  description = "ECR container image of the backend service implementation"
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones"
}

variable "acm_certificate_arn" {
  type        = string
  description = "Certificate manager requested certificate ARN"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone id for the customer domain"
}

variable "CI_PROJECT_DIR" {
  type        = string
  description = "Project path"
}
