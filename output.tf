output "ec2_instance_1" {
  value       = "${element(aws_instance.ec2_instance.*.id, 0)}"
 # sensitive   = false
 # description = "ec2 instances"
 # depends_on  = []
}

output "ec2_instance_2" {
  value       = "${element(aws_instance.ec2_instance.*.id, 1)}"
}

output "subnet_1" {
  value       = "${element(aws_subnet.sub.*.id, 0)}"
}

output "subnet_2" {
  value       = "${element(aws_subnet.sub.*.id, 1)}"
}
