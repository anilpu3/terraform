# the below task should be done within your system (user system), later we would provision/create a new EC2 instance and ssh into the newly created instance.
# create ssh keys in the default directory or in the user specified directory (path)
# usin below command 
# ssh-keygen (defualt path)
# ssh-keygen -f /home/anil/ssh-key (custom path & name) - user can define his own path and name.
# the command would generate two files public key(.pub) and private key in the directory.
# id_rsa and id_rsa.pub (default)
# ssh-key and ssh-key.pub (custom files)
# make sure you copy the content (key details) from the file id_rsa.pub (extenstion with .pub) and paste in "public_key = " under "aws_key_pair" resource block.

# run the code.
# once the new ec2 instance is created.
# Connect to instance and select SSH client 
# copy the ssh command (remove .pem) 
# ssh -i "id_rsa.pem" root@ec2-35-173-211-92.compute-1.amazonaws.com (it looks like this before you remove .pem) under Example
# ssh -i "id_rsa" root@ec2-35-173-211-92.compute-1.amazonaws.com (after removin .pem)

# Jus in case, if it doesn't work
# Run this command, if necessary, to ensure your key is not publicly viewable. 
# chmod 400 id_rsa (you should run this command, where you had initialy generated 2 keys in your system)


#--------------------------------------------------------------------------------------------------------
# provider
provider "aws" {
  region = "us-east-1"
}
#--------------------------------------------------------------------------------------------------------

# creatin instance 
resource "aws_instance" "ssh_instance" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh-sg-ec2.id]
  key_name               = "id_rsa"
  
tags = {
  Name = "SSH-Instance"
}
}
#----------------------------------------------------------------------------------------------------------

# creatin public key pair
resource "aws_key_pair" "ssh" {
  key_name   = "id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCsEB6W1ea/JLKzBuU+q81p2H3LH70JUEsKLn5yylHMbNFoXMElautz5XacNBwYe/z1c1R4cnrs4Jw2UUHSnU2FmvXPW351cgbhwK4ESfx43+QlLd9pjl5bfNZTbOZTIogxhYtRKwMQJ8g6NBMJdWTFlPRnqD/iPDvVigN5/SUH+Cm79L5Z3CDmz9H3x2zq6aB6uYjzHdVpAxe/5Kva5ykfhsaSNTMbXb9hLxjbErElAr1eH/0CVOIwl7gBY6BF0FrBot+Dq7ULTK7IvEw7PSXK6Fizey1SlIotO5cG8QPOg7D0ap3sQYGfdvVGcAF0QGq9VhFa6WU4dhpd3VIrRKLniZCZcmZMYziRfGS6aDZz2Z37wyvOvSFDGYKd7uqNCi3RXecTzCmmxDrjrjoKdBn0n8PLxlvBJkQO+Xzgd1+Asda1JQmWeBOAS8y1fVg+x5/XfL/LyayXpKSPMdn/UxWagu3yxdLkUGOVo4jyBbrKdV2AbmeL+AMl3x04X8AUpk= root@ambi"
}
#----------------------------------------------------------------------------------------------------------

# creating security group and vpc(default) - 22 port should be open for ssh
resource "aws_default_vpc" "ssh-default-vpc" {
}
resource "aws_security_group" "ssh-sg-ec2" {
  name        = "ssh-security_group"
  description = "security_group for autoscalin"
  vpc_id      = aws_default_vpc.ssh-default-vpc.id
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
#-----------------------------------------------------------------------------------------------------------



