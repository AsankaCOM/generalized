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

variable "volume_size" {
  description = "volume size of an instance"
  type        = string
}

variable "module_type" {
  description = "type of an instance"
  type        = string
}

variable "availability_zone" {
  description = "availabilty zone"
  type        = string
}

variable "instance_profile" {
  description = "instance profile"
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

variable "identifier" {
  
}


variable "vpc_id" {}