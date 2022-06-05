/*
 * Create an ECS cluster
 */
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"

  tags = var.tags
}
