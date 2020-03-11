output "instance_created" {
  value = aws_instance.ec2_instance
}

output "sg_created" {
  value = aws_security_group.sg_inst
}
