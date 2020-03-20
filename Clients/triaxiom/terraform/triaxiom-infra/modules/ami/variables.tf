variable "instance_ami" {
  description = "AMI used for the instance"
  default     = ""
  type        = string
}

variable "instance_type" {
  description = "Type used for the instance"
  default     = ""
  type        = string
}

variable "instance_key_name" {
  description = "Instance key used to ssh access"
  default     = ""
  type        = string
}

variable "instance_subnet" {
  description = "Subnets id to launch the instance"
  default     = ""
  type        = string
}

variable "volume_size" {
  description = "Volume size of an instance"
  default     = ""
  type        = string
}

variable "module_type" {
  description = "Type of an instance"
  default     = ""
  type        = string
}

variable "availability_zone" {
  description = "Availabilty zone"
  default     = ""
  type        = string
}

variable "instance_profile" {
  description = "Instance profile"
  default     = ""
  type        = string
}

variable "inbound_rules" {
  description = "Inbound rules"
  default     = [
    {
      from_port = 0
      to_port   = 0
      cidr      = "0.0.0.0/0"
      protocol  = "-1"
    }
  ]
  type        = list(any)
}

variable "outbound_rules" {
  description = "Outbound rules"
  default     = [
    {
      from_port = 0
      to_port   = 0
      cidr      = "0.0.0.0/0"
      protocol  = "-1"
    }
  ]
  type        = list(any)
}

variable "identifier" {
  description = "Name for the AMIS"
  default     = ""
  type        = string
}


variable "vpc_id" {
  description = "VPC where the instances will be deployed"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}