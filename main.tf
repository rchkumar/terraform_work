provider "aws" {

  region = "ap-southeast-3"

}

resource "aws_instance" "ec2-instance-my" {

ami = "ami-0483d92a8124da6c9"
instance_type = "t3.micro"

  tags = {

    Name = "TestGroup"
  }

}