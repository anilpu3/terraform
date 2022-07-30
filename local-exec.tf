provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "local-exec-instance" {
   ami = "ami-08d4ac5b634553e16"
   instance_type = "t2.micro"

tags = {
    Name = "local-exec"
  }

   provisioner "local-exec" {
    command = "echo ${aws_instance.local-exec-instance.private_ip} >> private_ips.txt" # this would create an instance and copy the private ip of the created instance to the text file "private_ips.txt" 
  }
}
