provider "aws" {
    region = "us-west-2"
}

terraform {
    backend "s3" {
        bucket = "shariq-terraform1"
        key = "state.tfstate"
        region = "us-west-2"
    }
}

module "network" {
  source = "./modules/network"
  cidr = "${var.cidr}"
  availability_zones = "${var.availability_zones}"
  region = "${var.region}"
}

module "iam" {
  source = "./modules/iam"
}

module "onetick" {
  source = "./modules/ami"
  instance_ami      = var.onetick_ami
  instance_type     = var.onetick_instance_type
  instance_key_name = var.onetick_instance_key_name
  identifier        = "${var.identifier}-onetick"
  instance_subnet   = module.network.private_subnet_id
  vpc_id            = module.network.vpc.id
  availability_zone = var.availability_zones[0]
  volume_size = var.onetick_vol_size
  module_type = "onetick"
  instance_profile = ""
}

module "app" {
  source = "./modules/ami"
  instance_ami      = var.app_ami
  instance_type     = var.app_instance_type
  instance_key_name = var.app_instance_key_name
  identifier        = "${var.identifier}-app"
  instance_subnet   = module.network.public_subnet_id
  vpc_id            = module.network.vpc.id
  availability_zone = var.availability_zones[0]
  volume_size = var.app_vol_size
  module_type = "app"
  instance_profile = module.iam.node_profile.id
}

module "bastion" {
  source = "./modules/ami"

  instance_ami      = var.bastion_ami
  instance_type     = var.bastion_instance_type
  instance_key_name = var.bastion_instance_key_name
  identifier        = "${var.identifier}-bastion"
  instance_subnet   = module.network.public_subnet_id
  vpc_id            = module.network.vpc.id
  availability_zone = var.availability_zones[0]
  volume_size = ""
  module_type = "bastion"
  instance_profile = ""
}
