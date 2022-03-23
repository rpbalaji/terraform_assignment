resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "internal-link"
  security_group_ids = [aws_security_group.vpc-link-sg.id]
  subnet_ids         = aws_subnet.private_subnet.*.id
}

resource "aws_apigatewayv2_api" "api-gate" {
  name          = "api-gateway"
  protocol_type = "HTTP"

}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id             = aws_apigatewayv2_api.api-gate.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_alb_listener.http-listner.arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id
}

resource "aws_apigatewayv2_route" "api-route" {
  api_id    = aws_apigatewayv2_api.api-gate.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api-gate.id
  name        = "$default"
  auto_deploy = true

}


resource "aws_apigatewayv2_deployment" "default-deployment" {
  api_id     = aws_apigatewayv2_api.api-gate.id
  depends_on = [aws_apigatewayv2_integration.api_integration, aws_apigatewayv2_stage.api_stage, aws_apigatewayv2_route.api-route]


}

