locals {
  default_tags = {
      Environment = terraform.workspace
      Name        = "${var.identifier}-${terraform.workspace}"
      }

  tags         = merge(local.default_tags, var.tags)
}

resource "aws_security_group" "sg_inst" {
  description       = "security group for instance"
  vpc_id            = var.vpc_id
  name              = "${var.identifier}-${terraform.workspace}"
  dynamic "ingress"{
      for_each      = [for r in var.inbound_rules:{
        f_port      = r.from_port
        t_port      = r.to_port
        cidr        = r.cidr
        protocol    = r.protocol
      }
    ]
    content {
        from_port   = ingress.value.f_port
        to_port     = ingress.value.t_port
        protocol    = ingress.value.protocol
        cidr_blocks = [ingress.value.cidr]
    }
  }

  dynamic "egress"{
     for_each       = [for r in var.outbound_rules:{
        f_port      = r.from_port
        t_port      = r.to_port
        cidr        = r.cidr
        protocol    = r.protocol
      }
    ]
    content {
        from_port   = egress.value.f_port
        to_port     = egress.value.t_port
        protocol    = egress.value.protocol
        cidr_blocks = [egress.value.cidr]
    } 
  }

  tags  = local.tags
}

resource "aws_eip" "bastion" {
  count = var.module_type == "bastion" ? 1 : 0

  instance = "${aws_instance.ec2_instance.id}"
  vpc      = true

  tags  = local.tags
}

resource "aws_instance" "ec2_instance" {
  vpc_security_group_ids = [aws_security_group.sg_inst.id]
  iam_instance_profile   = var.module_type == "app" ? var.instance_profile : null
  instance_type          = var.instance_type
  user_data              = var.module_type != "bastion" ? "${file("${path.module}/files/mount_vol.sh")}" : null
  subnet_id              = var.instance_subnet
  key_name               = var.instance_key_name
  ami                    = var.instance_ami

  tags                   = local.tags
}

resource "aws_ebs_volume" "cold_volume" {
  count = var.volume_size != "" ? 1 : 0
  
  availability_zone = var.availability_zone
  size              = var.volume_size
  type              = "sc1"

  tags              = local.tags
}

resource "aws_volume_attachment" "device_attach" {
  count = var.volume_size != "" ? 1 : 0

  device_name = "/dev/xvdf"
  instance_id = aws_instance.ec2_instance.id
  volume_id   = aws_ebs_volume.cold_volume[0].id
}