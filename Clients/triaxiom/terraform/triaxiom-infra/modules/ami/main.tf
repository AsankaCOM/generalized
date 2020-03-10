resource "aws_instance" "ec2_instance" {
  instance_type = var.instance_type
  ami           = var.instance_ami
  subnet_id     = var.instance_subnet
  key_name      = var.instance_key_name
}
