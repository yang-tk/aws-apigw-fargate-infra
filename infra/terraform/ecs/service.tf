# ECS Fargate service
resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.family
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  # Different platform_version requires different private VPC links integration
  # If later need to update the version, vpc_endpoints file need to be changed 
  # reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html
  platform_version = "1.3.0"

  network_configuration {
    security_groups  = [var.aws_security_group_ecs_tasks_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_tg.arn
    container_name   = var.name
    container_port   = var.app_port
  }

  depends_on = [
    aws_ecs_cluster.main,
    aws_ecs_task_definition.main,
  ]
}
