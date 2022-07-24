/*
 * Create an Network Load Balancer to distribute client requests
 * The listener will forward requests to the target groups
 * Target group will route traffic to registered target groups
 */
resource "aws_lb" "nlb" {
  name               = "${var.app_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.id
  port              = var.app_port
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.nlb_tg.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = "${var.stage}-nlb-tg"
  port        = var.app_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  depends_on = [
    aws_lb.nlb
  ]
}