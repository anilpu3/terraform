
provider "aws" {
  region = "us-east-1"
}

# creatin vpc
resource "aws_vpc" "test" {
  cidr_block =  "10.0.0.0/16"
  tags = {
    Name = "vpc_by_test"
  }
}

# creatin subnets (public -2 )

resource "aws_subnet" "sub_one" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "sub_two" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet_2"
  }
}

# creatin IG and attaching it to VPC

resource "aws_internet_gateway" "test-ig" {
  vpc_id = aws_vpc.test.id
  tags = {
    Name = "Internet Gateway"
  }
}

# creatin public route table and attach the Internet gateway

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
/*
# creatin private route table

resource "aws_route_table" "rtb_private" {
	vpc_id = "${aws_vpc.test.id}"
	
	tags = {
		Name = "Private_Route_Table"
	}
}
*/

# attachin public subnets to public route table

resource "aws_route_table_association" "rta_subnet_public_1" {
  subnet_id      = aws_subnet.sub_one.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "rta_subnet_public_2" {
  subnet_id      = aws_subnet.sub_two.id
  route_table_id = aws_route_table.rtb_public.id
}

/*
# attachin private subnets to private route table

resource "aws_route_table_association" "rta_subnet_private" {
	subnet_id = "${aws_subnet.sub_three.id}"
	route_table_id = "${aws_route_table.rtb_private.id}"
}
*/

# creatin security group

resource "aws_security_group" "sg_test" {
  # name = "newvpc"
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

# creatin 2 instances

resource "aws_instance" "alb_instance_1" {
  ami                         = "ami-08d4ac5b634553e16"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sub_one.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_test.id]
  user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>Hello this s Instance_1 </h1></body></html>" > /var/www/html/index.html
EOF

tags = {
    Name = "ALB_Test_Instance_1"
}

}

resource "aws_instance" "alb_instance_2" {
  ami                         = "ami-08d4ac5b634553e16"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sub_two.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_test.id]
  user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>Hello this s Instance_2 </h1></body></html>" > /var/www/html/index.html
EOF

tags = {
    Name = "ALB_Test_Instance_2"
}

}

# creatin alb
resource "aws_lb" "my-test-lb" {
  name               = "my-test-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  subnets            = ["${aws_subnet.sub_one.id}", "${aws_subnet.sub_two.id}"]

  enable_deletion_protection = false

}

# creatin target group and attachin the target group to the instances
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

resource "aws_lb_target_group_attachment" "my-tg-attachment1" {
  target_group_arn = aws_lb_target_group.my-alb-tg.arn
  target_id        = aws_instance.alb_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my-tg-attachment2" {
  target_group_arn = aws_lb_target_group.my-alb-tg.arn
  target_id        = aws_instance.alb_instance_2.id
  port             = 80
}

# creatin listners
resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.my-test-lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my-alb-tg.arn}"
  }
}
