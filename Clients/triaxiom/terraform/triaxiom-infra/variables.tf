variable "cidr" {
  default = "172.16.0.0/16"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-west-2a","us-west-2b","us-west-2c"]
}

variable "region" {
  default = "us-west-2"
}

variable "identifier" {
  default = "triaxiom"
}

variable "onetick_ami" {}

variable "app_ami" {}

variable "bastion_ami" {}


variable "onetick_instance_type" {}

variable "app_instance_type" {}

variable "bastion_instance_type" {}


variable "onetick_instance_key_name" {}

variable "app_instance_key_name" {}

variable "bastion_instance_key_name" {}

