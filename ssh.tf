# provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ssh_instance" {
  ami                         = "ami-08d4ac5b634553e16"
  instance_type               = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh-sg-ec2.id]
  key_name   = "ssh-key"
  }

tags = {
    Name = "SSH-Instance"
  }


# creating security group and vpc(default)

resource "aws_default_vpc" "ssh-default-vpc" {
}
resource "aws_security_group" "ssh-sg-ec2" {
  name        = "asg-security_group"
  description = "security_group for autoscalin"
  vpc_id      = aws_default_vpc.asg-default-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.ssh-default-vpc.cidr_block]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh-security-group"
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
