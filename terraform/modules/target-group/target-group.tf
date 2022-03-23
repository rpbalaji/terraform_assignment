resource "aws_lb_target_group" "service1_tg" {
  name        = var.tg_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}