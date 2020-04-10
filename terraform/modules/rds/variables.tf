variable "vpc_id" {
  description = "VPC id for the resources"
  default     = ""
  type        = string
}

variable "security_group_id" {
  description = "Security group"
  default     = ""
  type        = string
}

variable "subnets" {
  description = "A list of VPC subnet IDs"
  default     = []
  type        = list(string)
}

variable "database_name" {
  description = "Name of the database"
  default     = "parveendev"
  type        = string
}

variable "rds_master_username" {
  description = "Master username for the database"
  default     = "parveen"
  type        = string
}

variable "rds_allocated_storage" {
  description = "Allocated storage"
  default     = 10
  type        = number
}

variable "multi_az" {
  description = "Set to 'true' to deploy the rds instance as multi-az"
  default     = false
  type        = bool
}

variable "backup_retention_period" {
  description = "Backup retention period"
  default     = 15
  type        = number
}

variable "engine" {
  description = "Define the engine for the database"
  default     = "postgres"
  type        = string
}

variable "engine_version" {
  description = "Define the engine version for the database"
  default     = ""
  type        = string
}

variable "instance_class" {
  description = "Define the instance class"
  default     = ""
  type        = string
}

variable "identifier" {
  description = "The name for the resources"
  default     = "mydb"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}
