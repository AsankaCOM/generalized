provider "aws" {
    region = "us-west-2"
}
module "network" {
  source = "./modules/network"
  cidr = "${var.cidr}"
  availability_zones = "${var.availability_zones}"
  region = "${var.region}"
}

module "onetick" {
  source = "./modules/ami"
  instance_ami      = var.onetick_ami
  instance_type     = var.onetick_instance_type
  instance_key_name = var.onetick_instance_key_name
  identifier        = "${var.identifier}-onetick"
  instance_subnet   = module.network.public_subnet_id
  vpc_id            = module.network.vpc.id
}

module "app" {
  source = "./modules/ami"
  instance_ami      = var.app_ami
  instance_type     = var.app_instance_type
  instance_key_name = var.app_instance_key_name
  identifier        = "${var.identifier}-app"
  instance_subnet   = module.network.public_subnet_id
  vpc_id            = module.network.vpc.id
}

module "bastion" {
  source = "./modules/ami"

  instance_ami      = var.bastion_ami
  instance_type     = var.bastion_instance_type
  instance_key_name = var.bastion_instance_key_name
  identifier        = "${var.identifier}-bastion"
  instance_subnet   = module.network.public_subnet_id
  vpc_id            = module.network.vpc.id

}
