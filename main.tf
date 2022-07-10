# Hardcoded
# Creatin 2 instances
# Creatin VPC
# Creatin 2 different subnets which belongs to 2 different availability zone
# Attachin newly created 2 instances with newly created 2 subnets
# Using the function "element"

provider "aws" {
  region = "us-east-1"
}

# Creatin 2 instances
resource "aws_instance" "ec2_instance" {
  ami                         = "ami-08d4ac5b634553e16"
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.sub.*.id, count.index)
  associate_public_ip_address = true
  count                       = "2"

  tags = {
    Name = element(["EC2_Instance_1", "EC2_Instance_2"], count.index)
  }

}

# creatin vpc
resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc_by_test"
  }
}


# creatin subnets (2 public)
resource "aws_subnet" "sub" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  count             = "2"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = element(["subnet_1", "subnet_2"], count.index)
  }
}

