variable "cidr" {
  default = "172.16.0.0/16"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-west-1a", "us-west-1c"]
}

variable "region" {
  default = "us-west-1"
}

variable "identifier" {
  default = "triaxiom"
}

variable "onetick_vol_size" {
  default = "500"
}

variable "app_vol_size" {
  default = "500"
}


variable "onetick_ami" {
  default = "ami-05928e7116d7804f0"
}

variable "app_ami" {
  default = "ami-043ee0cd4ebde7ba7"
}

variable "bastion_ami" {
  default = "ami-01c94064639c71719"
}


variable "onetick_instance_type" {
  default = "t2.medium"
}

variable "app_instance_type" {
  default = "t2.medium"
}

variable "bastion_instance_type" {
  default = "t2.micro"
}


variable "onetick_instance_key_name" {
  default = "triaxiom.devops"
}

variable "app_instance_key_name" {
  default = "triaxiom.devops"
}

variable "bastion_instance_key_name" {
  default = "triaxiom.devops"
}