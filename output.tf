output "output_vpc_id" {
  value       = aws_vpc.test.id
 # sensitive   = false
#  description = "its a VPC ID"
 # depends_on  = []
}

output "output_subnet_one" {
  value = aws_subnet.sub_one.id
}

output "output_subnet_two" {
  value = aws_subnet.sub_two.id
}

output "output_security_group" {
  value = aws_security_group.sg_test.id
}

output "output_instance_1" {
  value = aws_instance.alb_instance_1.id
}

output "output_instance_2" {
  value = aws_instance.alb_instance_2.id
}

output "output_alb" {
  value = aws_lb.my-test-lb.id
}

output "output_lb_target_group" {
  value = aws_lb_target_group.my-alb-tg.id
}

output "output_lb_listener" {
  value = aws_lb_listener.my-test-alb-listner.id
}
