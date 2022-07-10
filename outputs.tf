output "public_ip" {
  value = aws_instance.ec2-instance-my.public_ip
}

output "seid" {
  value = aws_security_group.instance-sg.id
}