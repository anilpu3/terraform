#------------------------------------------------------------------------------------------------------------------
# provider
provider "aws" {
  region = "us-east-1"
}
#------------------------------------------------------------------------------------------------------------------
# creatin VPC
resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc_by_test"
  }
}
#---------------------------------------------------------------------------------------------------------------------
# creatin subnets (2 public)
resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index) # different availability zone
  count             = "2"
  tags = {
    Name = element(["public_subnet_1", "public_subnet_2"], count.index)
  }
}
#-------------------------------------------------------------------------------------------------------------------
# creatin IG and attachin it to VPC

resource "aws_internet_gateway" "test-ig" {
  vpc_id = aws_vpc.test.id
  tags = {
    Name = "Internet Gateway"
  }
}
# -------------------------------------------------------------------------------------------------------------------
# creatin public route table and attachin the Internet gateway

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-ig.id
  }
  tags = {
    Name = "Public_Route_Table"
  }
}
#-----------------------------------------------------------------------------------------------------------------------
# attachin public subnets to public route table

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  count          = "2"
  route_table_id = aws_route_table.rtb_public.id
}
#--------------------------------------------------------------------------------------------------------------------
# creatin security group

resource "aws_security_group" "sg_test" {
  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "Security Group"
  }

}
#-----------------------------------------------------------------------------------------------------------------
# creatin instances

resource "aws_instance" "alb_instances" {
  ami                         = "ami-08d4ac5b634553e16"
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public_subnets.*.id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_test.id]
  count                       = "2"
  user_data                   = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1> Hello from Instance $(hostname -f) </h1></body></html>" > /var/www/html/index.html
EOF

  tags = {
    Name = element(["ALB_Instance_1", "ALB_Instance_2"], count.index)
  }
}

#------------------------------------------------------------------------------------------------------------------------
# creatin alb

resource "aws_lb" "my-test-lb" {
  name               = "my-test-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  #subnets            = ["${aws_subnet.sub_one.id}", "${aws_subnet.sub_two.id}"]
  subnets                   = "${(aws_subnet.public_subnets.*.id)}" 
  enable_deletion_protection = false

}
#-------------------------------------------------------------------------------------------------------------------------
# creatin target group, health check and attachin the instances to target group

resource "aws_lb_target_group" "my-alb-tg" {
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  name        = "my-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "my-tg-attachments" {
  target_group_arn = aws_lb_target_group.my-alb-tg.arn
  target_id        = element(aws_instance.alb_instances.*.id, count.index)
  count            = "2"
  port             = 80
}
#----------------------------------------------------------------------------------------------------
# creatin listener

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = aws_lb.my-test-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-alb-tg.arn
  }
}
#------------------------------------------------------------------------------------------------------
