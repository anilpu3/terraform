#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# provider
provider "aws" {
  region = "us-east-1"
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# creatin new instane, connection thru remote-exec and git installation via ansible playbook usin local-exec provisioner

resource "aws_instance" "local-exec-instance" {
   ami = "ami-08d4ac5b634553e16"
   instance_type = "t2.micro"
   key_name = "door-key"
  
  tags = {
    Name = "Git-Installed-Instance"
  }

   connection {
   type     = "ssh"
   user     = "ubuntu"
   private_key = file("./door-key.pem")
   #private_key = file("./ssh-key")
   host     = self.public_ip     # public ip of the newly created instance.         
    }
provisioner "remote-exec" {
   inline = [
     "echo 'establishin ssh connection'",
     "sudo apt-get update"                           # optional, can be configured in ansible playbook
        ]
 }

provisioner "local-exec" {
command = "sleep 60"                                 # optional
}

provisioner "local-exec" {                           #optional
command = "echo aws_instance.local-exec-instance.private.ip > private-ips.txt" 
}

provisioner "local-exec" { # git installation on target machine usin ansible playbook
    command = "ansible-playbook  -i ${aws_instance.local-exec-instance.private_ip}, --private-key ${"./door-key.pem"} git-install.yml"
  }

}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
