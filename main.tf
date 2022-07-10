provider "aws" {

  region = "ap-southeast-3"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

}




resource "aws_launch_configuration" "ec2-instance-my" {

  image_id               = "ami-0483d92a8124da6c9"
  instance_type          = "t3.micro"
  #vpc_security_group_ids = [aws_security_group.instance-sg.id]

  user_data = <<-EOF
                #!/bin/bash
                 echo "Hello, World" > index.html
                 nohup busybox httpd -f -p ${var.server_port} &
                 EOF



  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "instance-sg" {

  name = "terraform-instance-sg"

  ingress {
    from_port   = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = var.server_port

  }


}


resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.ec2-instance-my.name
 # vpc_zone_identifier  = [data.aws_subnets.default.ids]
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"
  min_size             = 2
  max_size             = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

}
resource "aws_lb" "lb-example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb-sg.id]
}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb-example.arn
  port              = 80
  protocol          = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404

    }
  }
}

resource "aws_security_group" "alb-sg" {

  name = "terraform-example-alb"
  # allow inbound http requests

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb_target_group" "asg" {

  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "https"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "https"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
  condition {

    path_pattern {
      values = ["*"]
    }
  }
}