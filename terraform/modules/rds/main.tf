resource "aws_db_instance" "default" {
    identifier                  = var.identifier
    allocated_storage           = var.rds_allocated_storage
    engine                      = var.engine
    engine_version              = var.engine_version
    instance_class              = var.instance_class
    name                        = var.database_name
    username                    = var.rds_master_username
    password                    = random_password.password.result
    multi_az                    = var.multi_az
    vpc_security_group_ids      = [var.security_group_id]
    tags                        = var.tags
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}