provider "aws" {
    region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "luis-bucket-tests"
    key = "state.tfstate"
    region = "us-west-2"
  }
}

module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  identifier         = var.identifier
  region             = var.region
  cidr               = var.cidr
  tags               = var.tags
}

module "iam" {
  source = "./modules/iam"

  identifier  = var.identifier
  tags        = var.tags
}

module "onetick" {
  source = "./modules/ami"

  availability_zone = var.availability_zones[0]
  instance_key_name = var.onetick_instance_key_name
  instance_profile  = ""
  instance_subnet   = module.network.private_subnet_id
  instance_type     = var.onetick_instance_type
  instance_ami      = var.onetick_ami
  volume_size       = var.onetick_vol_size
  module_type       = "onetick"
  identifier        = "${var.identifier}-onetick"
  vpc_id            = module.network.vpc.id
  tags              = var.tags
}

module "app" {
  source = "./modules/ami"

  availability_zone = var.availability_zones[0]
  instance_key_name = var.app_instance_key_name
  instance_profile  = module.iam.node_profile.id
  instance_subnet   = module.network.private_subnet_id
  instance_type     = var.app_instance_type
  instance_ami      = var.app_ami
  volume_size       = var.app_vol_size
  module_type       = "app"
  identifier        = "${var.identifier}-app"
  vpc_id            = module.network.vpc.id
  tags              = var.tags
}

module "bastion" {
  source = "./modules/ami"

  availability_zone = var.availability_zones[0]
  instance_key_name = var.bastion_instance_key_name
  instance_profile  = ""
  instance_subnet   = module.network.public_subnet_id
  instance_type     = var.bastion_instance_type
  instance_ami      = var.bastion_ami
  volume_size       = var.bastion_vol_size
  module_type       = "bastion"
  identifier        = "${var.identifier}-bastion"
  vpc_id            = module.network.vpc.id
  tags              = var.tags
}
