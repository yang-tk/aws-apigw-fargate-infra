/*
 * Create an ECR to store our backend service image
 */
resource "aws_ecr_repository" "main" {
  name                 = "${var.app_name}-ecr-image"

  tags = var.tags
}