variable "availability_zones" {
    description = "List of availability zones where subnets will be deployed"
    default     = []
    type        = list(string)
}

variable "cidr" {
    description = "Range of IPv4 addresses for your VPC in CIDR block format"
    default     = ""
    type        = string
}

variable "description" {
    description = "A description for the VPC"
    default     = "VPC created by terraform"
    type        = string
}

variable "identifier" {
    description = "Name of the VPC"
    default     = ""
    type        = string
}

variable "region" {
    description = "Region where the VPC will be deployed"
    default     = "us-west-2"
    type        = string
}

variable "tags" {
    description = "Tags to be applied to the resource"
    default     = {}
    type        = map
}