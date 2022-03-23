resource "aws_ecs_task_definition" "service" {
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "arn:aws:iam::136374005149:role/ecsTaskExecutionRole"
  cpu = "256"
  network_mode = "awsvpc"
  memory = "512"
  container_definitions = jsonencode([
    {
      name = var.container_name
      image = var.image
      operating_system_family = "LINUX"
      command = ["/start.sh"]
      entryPoint = ["/entrypoint.sh"]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
     }
  ])
  family = "${var.container_name}_service"
}

resource "aws_ecs_service" "service1" {
  name = "${var.container_name}_ser"
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.service.arn
  cluster = var.ecs_id
  desired_count = 1
  deployment_maximum_percent = 200
  network_configuration {
    assign_public_ip =  "false"
    security_groups = [var.ecs_security_group]
    subnets = [var.ecs_subnet]
  }
  load_balancer {
    target_group_arn = var.tg_arn
    container_name = var.container_name
    container_port = 80
  }
}