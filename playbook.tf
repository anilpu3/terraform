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
     "sudo apt-get update"                           # optional, can also be configured in ansible playbook
        ]
 }

provisioner "local-exec" {
command = "sleep 30"                                 # optional - used to wait 30sec to perform next cmd 
}

provisioner "local-exec" {                           #optional
command = "echo aws_instance.local-exec-instance.private.ip > private-ips.txt" 
}

provisioner "local-exec" { # git installation on target host machine usin ansible playbook
    command = "ansible-playbook -i ${aws_instance.local-exec-instance.private_ip}, --private-key ${"./door-key.pem"} git-install.yml"
  }

}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
  By default, the user ansible connects to remote servers as the same name as the user ansible runs as.
  it will try to connect to remote servers with whatever user started name with. You can override this by specifyin
  the remote_user in a playbook or globally in the ansible.cfg file.
------------------------------------------------------------------------------------  -
  cat <<EOF > /root/ansible/git-install.yml
  ---
- hosts: all
  remote_user: ubuntu                   # configured in playbook
  tasks:
    - name: install pakage
      apt:
        name: git
        state: latest
      become: yes
EOF
-----------------------------------------------------------------------------------------  
cat <<EOF > /root/ansible/ansible.cfg
[defaults]
inventory = ./inventory
deprecation_warnings = False
remote_user = ubuntu                   # configured in ansible.cfg file (configuration file - can be used to do lot more than this)
host_key_checking = False
private_key_file = ./door-key.pem

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = False
EOF
*/
  


