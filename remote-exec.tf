#------------------------------------------------------------------------------------------------------------------------
# provider
provider "aws" {
  region = "us-east-1"
}
#------------------------------------------------------------------------------------------------------------------------
# creatin new instane, connection & remote-exec provisioner

resource "aws_instance" "remote-exec-instance" {
   ami = "ami-08d4ac5b634553e16"
   instance_type = "t2.micro"
   key_name = "door-key"
  
  tags = {
    Name = "remote-exec"
  }
   connection {
   type     = "ssh"
   user     = "ubuntu"
   private_key = file("F:/a/terraform/door-key.pem")
   #private_key = file("./door-key.pem")
   host     = self.public_ip     # public ip of the newly created instance.         
    }

 provisioner "remote-exec" {
   inline = [
      "sudo apt-get update",
      #"sudo apt install -y apache2",
      "sudo apt install git"
      
   ]
 }
}
#-------------------------------------------------------------------------------------------------------------------------








