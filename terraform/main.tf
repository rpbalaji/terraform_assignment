resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    usecase = local.common_tag
    Name    = "mainvpc"
  }
}


resource "aws_iam_policy" "ecr_pulll" {
  name        = "ecr-pulll"
  description = "A ecr policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetRegistryPolicy",
                "ecr:DescribeImageScanFindings",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:GetDownloadUrlForLayer",
                "ecr:DescribeRegistry",
                "ecr:DescribePullThroughCacheRules",
                "ecr:DescribeImageReplicationStatus",
                "ecr:GetAuthorizationToken",
                "ecr:ListTagsForResource",
                "ecr:ListImages",
                "ecr:BatchGetRepositoryScanningConfiguration",
                "ecr:GetRegistryScanningConfiguration",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr:DescribeRepositories",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetRepositoryPolicy",
                "ecr:GetLifecyclePolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attachement-policy" {
  role       = "ecsTaskExecutionRole"
  policy_arn = aws_iam_policy.ecr_pulll.arn
}

resource "aws_subnet" "public_subnet" {

  count             = var.public_sb_count
  cidr_block        = element(var.public_sub_cidr, count.index)
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = element(var.az, "${count.index}")
  tags = {
    usecase = local.common_tag
    Name    = "public_subnet_${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.private_sb_count
  cidr_block        = element(var.private_sub_cidr, count.index)
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = element(var.az, "${count.index}")
  tags = {
    usecase = local.common_tag
    Name    = "private_subnet_${count.index}"
  }
}

resource "aws_internet_gateway" "myinternet" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    usecase = local.common_tag
  }
}


resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myinternet.id
  }
  tags = {
    usecase = local.common_tag
    Name    = "public_route"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    usecase = local.common_tag
    Name    = "private_route"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public_sb_count
  route_table_id = aws_route_table.public_route.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = var.private_sb_count
  route_table_id = aws_route_table.private_route.id
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}




resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_id              = aws_vpc.myvpc.id
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id
  security_group_ids  = [aws_security_group.endpoint-sg.id]
  tags = {
    Name = "ecr-api-endpoint"
  }
}


resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_id              = aws_vpc.myvpc.id
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet.*.id
  security_group_ids  = [aws_security_group.endpoint-sg.id]
  tags = {
    Name = "ecr-dkr-endpoint"
  }
}


resource "aws_vpc_endpoint" "s3-gateway-endpoint" {
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.myvpc.id
  route_table_ids   = [aws_route_table.private_route.id]
  tags = {
    Name = "s3-gateway-endpoint"
  }
}

resource "aws_vpc_endpoint" "logs-ep" {
  service_name        = "com.amazonaws.us-east-1.logs"
  vpc_id              = aws_vpc.myvpc.id
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_subnet.*.id
  security_group_ids  = [aws_security_group.endpoint-sg.id]
  tags = {
    Name = "cloudwatch-endpoint"
  }

}

module "pub-lb" {
  source     = "../terraform/modules/lb/"
  albname    = "pub-alb"
  albtype    = true
  albsg      = [aws_security_group.pub-lb-sg.id]
  alb_subnet = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
}

module "pri-lb" {
  source     = "../terraform/modules/lb/"
  albname    = "pri-alb"
  albtype    = true
  albsg      = [aws_security_group.pub-lb-sg.id]
  alb_subnet = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
}

module "s1-tg" {
  source  = "../terraform/modules/target-group/"
  count   = var.tg_count
  tg_name = "service-${count.index + 1}"
  vpc_id  = aws_vpc.myvpc.id
}


resource "aws_alb_listener" "http-listner" {
  load_balancer_arn = module.pub-lb.pub_alb_arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = module.s1-tg[0].pub-tg-arn
  }
}

resource "aws_alb_listener" "http-private-listner" {
  load_balancer_arn = module.pri-lb.pub_alb_arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = module.s1-tg[1].pub-tg-arn
  }
}

