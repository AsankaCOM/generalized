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
  type        = "string"
}

variable "instance_subnet" {
  description = "subnets id to launch the instance"
  type        = "string"
}
