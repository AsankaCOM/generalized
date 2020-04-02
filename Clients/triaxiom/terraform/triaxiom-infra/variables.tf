variable "bucket" {
  description = "Backend bucket"
  default     = "triaxiom-teraform-state"
  type        = string
}

variable "cidr" {
  description = "Range of IPv4 addresses for your VPC in CIDR block format"
  default     = "172.16.0.0/16"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones where subnets will be deployed"
  default     = ["us-west-2a", "us-west-2b" ,"us-west-2c"]
  type        = list(string)
}

variable "region" {
  description = "Region where the resources will be deployed"
  default     = "us-west-2"
  type        = string
}

variable "identifier" {
  description = "Identifier for all the resources"
  default     = "triaxiom"
  type        = string
}

variable "onetick_vol_size" {
  description = "Volume size for one-tick instance"
  default     = "2000"
  type        = string
}

variable "app_vol_size" {
  description = "Volume size for app instance"
  default     = ""
  type        = string
}

variable "bastion_vol_size" {
  description = "Volume size for bastion instance"
  default     = ""
  type        = string
}

# amis
variable "onetick_ami" {
  description = "Ami for onetick instance"
  default     = "ami-0d04be32f605af0be"
  type        = string
}

variable "app_ami" {
  description = "Ami for app instance"
  default     = "ami-092401364d7a54995"
  type        = string
}

variable "bastion_ami" {
  description = "Ami for bastion instance"
  default     = "ami-0e8c04af2729ff1bb"
  type        = string
}

# instance types
variable "onetick_instance_type" {
  description = "Instance type for onetick instance"
  default     = "t2.medium"
  type        = string
}

variable "app_instance_type" {
  description = "Instance type for app instance"
  default     = "t2.medium"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion instance"
  default     = "t2.micro"
  type        = string
}

# keynames
variable "onetick_instance_key_name" {
  description = "Instance key name for onetick"
  default     = "triaxiom-oregon"
  type        = string
}

variable "app_instance_key_name" {
  description = "Instance key name for app instance"
  default     = "triaxiom-oregon"
  type        = string
}

variable "bastion_instance_key_name" {
  description = "Instance key name for bastion instance"
  default     = "triaxiom-oregon"
  type        = string
}

variable "tags" {
    description = "Tags to be applied to the resource"
    default     = {}
    type        = map
}