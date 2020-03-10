variable "instance_ami" {
  description = "AMI used for the instance"
  type        = "string"
}

variable "instance_type" {
  description = "type used for the instance"
  type        = "string"
}

variable "instance_key_name" {
  description = "instance key used to ssh access"
  type        = string
}

variable "instance_subnet" {
  description = "subnets id to launch the instance"
  type        = string
}

variable "inbound_rules" {
  default = [
    {
      from_port = 0
      to_port = 0
      cidr = "0.0.0.0/0"
      protocol = "-1"
    }
  ]
}

variable "outbound_rules" {
  default = [
    {
      from_port = 0
      to_port = 0
      cidr = "0.0.0.0/0"
      protocol = "-1"
    }
  ]
}

variable "vpc_id" {}