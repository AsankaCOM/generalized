variable "identifier" {
    description = "Name of the IAM role"
    default     = ""
    type        = string
}

variable "tags" {
    description = "Tags to be applied to the resource"
    default     = {}
    type        = map
}
