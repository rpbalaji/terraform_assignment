resource "aws_ecs_cluster" "s1-ecs" {
  name = "service1"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


module "ecs-s1" {
  source             = "../terraform/modules/ecs/"
  container_name     = "service1"
  ecs_id             = aws_ecs_cluster.s1-ecs.id
  ecs_security_group = aws_security_group.service-sg.id
  ecs_subnet         = aws_subnet.private_subnet[0].id
  image              = "136374005149.dkr.ecr.us-east-1.amazonaws.com/service1:latest"
  tg_arn             = module.s1-tg[0].pub-tg-arn
  depends_on         = [module.pri-lb, module.pub-lb, module.s1-tg, aws_vpc_endpoint.ecr-api-endpoint, aws_vpc_endpoint.ecr-dkr-endpoint, aws_vpc_endpoint.s3-gateway-endpoint]
}

resource "aws_ecs_cluster" "s2-ecs" {
  name = "service2"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


module "ecs-s2" {
  source             = "../terraform/modules/ecs/"
  container_name     = "service2"
  ecs_id             = aws_ecs_cluster.s2-ecs.id
  ecs_security_group = aws_security_group.service-sg.id
  ecs_subnet         = aws_subnet.private_subnet[0].id
  image              = "136374005149.dkr.ecr.us-east-1.amazonaws.com/service2:latest"
  tg_arn             = module.s1-tg[1].pub-tg-arn
  depends_on         = [module.pri-lb, module.pub-lb, module.s1-tg, aws_vpc_endpoint.ecr-api-endpoint, aws_vpc_endpoint.ecr-dkr-endpoint, aws_vpc_endpoint.s3-gateway-endpoint]
}