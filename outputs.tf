
output "seid" {
  value = aws_security_group.instance-sg.id
}

output "alb_dns_name" {
  value       = aws_lb.lb-example.dns_name
  description = "The domain name of the load balancer"
}