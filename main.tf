provider "aws" {

  region = "ap-southeast-3"

}

resource "aws_instance" "ec2-instance-my" {

  ami           = "ami-0483d92a8124da6c9"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance-sg.id]

  user_data = <<-EOF
                #!/bin/bash
                 echo "Hello, World" > index.html
                 nohup busybox httpd -f -p ${var.server_port} &
                 EOF


  tags = {

    Name = "TestGroup"
  }

}

resource "aws_security_group" "instance-sg" {

  name = "terraform-instance-sg"

  ingress {
    from_port = var.server_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port = var.server_port

  }


}