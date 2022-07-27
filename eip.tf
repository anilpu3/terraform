# attach eip to an instance.
# eip (elastic ip address), it s a static public ip address - it means it s a public ip address which s constant, where the ip address doesn't change. 

# provider
provider "aws" {
  region     = "ap-south-1"
}

# creatin instance
resource "aws_instance" "eip-instance" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
}

# creatin eip and attachin it to the instance
resource "aws_eip" "eip-for-instance" {
instance = "${aws_instance.eip-instance.id}"
}
