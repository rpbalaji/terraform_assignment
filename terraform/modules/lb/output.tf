output "pub_alb_arn" {
  value = aws_lb.lb-mod.arn
}

output "pub_alb_dnsname" {
  value = aws_lb.lb-mod.dns_name
}