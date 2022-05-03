provider "aws" {
  region     = "ap-south-1"
}

provider "aws" {
region = "us-west-1"
alias = "us-cal"

}
resource "aws_instance" "ma-terraform" {
ami= "ami-0447a12f28fddb066"
instance_type = "t2.micro"
}

resource "aws_instance" "us-california" {
ami = "ami-0487b1fe60c1fd1a2"
instance_type = "t2.small"
provider = aws.us-cal
}
