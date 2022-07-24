/**
VPC endpoints (Private VPC link) integration depends on Fargate platform version 
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html
*/

# VPC endpoints (Private link) for ECR 
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id

  security_group_ids = [
    aws_security_group.ecs_tasks.id,
  ]

  tags = {
    Name        = "ECR Docker VPC Endpoint Interface - ${var.stage}"
  }
}

# VPC endpoints for CloudWatch
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_subnet.*.id
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.ecs_tasks.id,
  ]

  tags = {
    Name        = "CloudWatch VPC Endpoint Interface - ${var.stage}"
  }
}

# VPC endpoints for S3 (S3 is required as Amazon ECR uses Amazon Simple Storage Service (Amazon S3) to store the image layers)
# reference: https://aws.amazon.com/premiumsupport/knowledge-center/ecs-ecr-docker-image-error/
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.custom_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_vpc.custom_vpc.main_route_table_id]

  tags = {
    Name        = "S3 VPC Endpoint Gateway - ${var.stage}"
  }
}

# VPC endpoints for DynamoDB access
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.custom_vpc.id
  service_name        = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type   = "Gateway"
  route_table_ids   = [aws_vpc.custom_vpc.main_route_table_id]

  tags = {
    Name        = "DynamoDB VPC Endpoint Gateway - ${var.stage}"
  }
}