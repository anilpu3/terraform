#----------------------------------------------------------------
# provider
provider "aws" {
  region = "us-east-1"
}
#----------------------------------------------------------------
# creating autoscalin group
resource "aws_autoscaling_group" "asg-test" {
  # name                 = "asg-test"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 3
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = ["subnet-058f2142c9c7458f5","subnet-0af349aec17ba628a"]
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}
#----------------------------------------------------------------
# creating launch template for auto scalin
resource "aws_launch_template" "template" {
  name          = "asg-launch-template"
  instance_type = "t2.micro"
  image_id      = "ami-08d4ac5b634553e16"
  # ebs_optimized          = true
  vpc_security_group_ids = [aws_security_group.asg-sg-ec2.id]
}
#----------------------------------------------------------------
# creating autoscalin policy "target-trackin-policy"
resource "aws_autoscaling_policy" "target_trackin_policy" {
  name                      = "asg-target-trackin-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.asg-test.name
  estimated_instance_warmup = 0

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "20"

  }
}
#----------------------------------------------------------------
# creating security group and vpc(default)

resource "aws_default_vpc" "asg-default-vpc" {
}

resource "aws_security_group" "asg-sg-ec2" {
  name        = "asg-security_group"
  description = "security_group for autoscalin"
  vpc_id      = aws_default_vpc.asg-default-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.asg-default-vpc.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "asg-security-group"
  }
}
#-------------------------------------------------------------------
/* 
# data source for ami
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon", "self"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

#---------------------------------------------------------------------
*/
