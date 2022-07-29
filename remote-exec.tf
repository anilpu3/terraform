#------------------------------------------------------------------------------------------------------------------------
# provider
provider "aws" {
  region = "us-east-1"
}
#------------------------------------------------------------------------------------------------------------------------
# creatin new instane, connection & remote-exec provisioner

resource "aws_instance" "myec2" {
   ami = "ami-08d4ac5b634553e16"
   instance_type = "t2.micro"
   key_name = "door-key"

   connection {
   type     = "ssh"
   user     = "root"
   private_key = file("./a/terraform/door-key.pem")
   host     = self.public_ip     # public ip of the newly created instance.         
    }

 provisioner "remote-exec" {
   inline = [
      "sudo apt-get update"
      "sudo apt install -y apache2"
      "sudo systemctl status apache2"
      "sudo systemctl start apache2"
      "sudo chown -R $USER:$USER /var/www/html"
      "sudo echo "<html><body><h1> Hello from Instance $(hostname -f) </h1></body></html>" > /var/www/html/index.html"
   ]
 }
}
#-------------------------------------------------------------------------------------------------------------------------








#--------------------------------------------------------------------------------------------------------
/*
# creatin instance 
resource "aws_instance" "remote-exec_instance" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh-sg-ec2.id]
  key_name               = "id_rsa"
  
tags = {
  Name = "Remote-Exec-Instance"
}
}
*/
#----------------------------------------------------------------------------------------------------------
