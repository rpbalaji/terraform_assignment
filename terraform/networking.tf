resource "aws_route53_zone" "secondary" {
  name = "internal.net"
  vpc {
    vpc_id = aws_vpc.myvpc.id
  }
}

resource "aws_route53_record" "s2_53" {
  name    = "service2"
  type    = "CNAME"
  zone_id = aws_route53_zone.secondary.zone_id
  ttl     = 30
  records = [module.pri-lb.pub_alb_dnsname]
}

resource "aws_route53_record" "service1_53" {
  name    = "pythonservice"
  type    = "CNAME"
  zone_id = aws_route53_zone.secondary.zone_id
  ttl     = 30
  records = [module.pub-lb.pub_alb_dnsname]
}

resource "aws_security_group" "endpoint-sg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "service-sg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [var.vpc_cidr]
  }
  tags = {
    Name = "ecs-service-sg"
  }
}

resource "aws_security_group" "pub-lb-sg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [var.vpc_cidr]
  }
  tags = {
    Name = "public-alb-sg"
  }
}

resource "aws_security_group" "vpc-link-sg" {
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "api-gateway-sg"
  }
}



