/*
 * ECS Fargate running task definition
 * [environment] variable will be stored in the Fargate container and can be pulled
 * with System.env
 */
resource "aws_ecs_task_definition" "main" {
  family                   = var.app_name
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.main_ecs_tasks.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode([
    {
      name : var.app_name,
      image : var.app_image,
      cpu : var.fargate_cpu,
      memory : var.fargate_memory,
      networkMode : "awsvpc",
      portMappings : [
        {
          containerPort : var.app_port
          protocol : "tcp",
          hostPort : var.app_port
        }
      ],
      environment: [
        {
          name: "STAGE",
          value: var.stage
        },
        {
          name: "AWS_REGION",
          value: var.aws_region
        },
      ]
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-group : var.app_name,
          awslogs-region : var.aws_region,
          awslogs-create-group : "true",
          awslogs-stream-prefix : "${var.app_name}-logs"
        }
      }
    }
  ])
}
