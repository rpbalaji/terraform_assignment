resource "aws_lb" "lb-mod" {
  name               = var.albname
  internal           = var.albtype
  load_balancer_type = "application"
  security_groups    = var.albsg
  subnets            = var.alb_subnet

  enable_deletion_protection = false
  tags = {
    usecase = "zoom"
  }
}

