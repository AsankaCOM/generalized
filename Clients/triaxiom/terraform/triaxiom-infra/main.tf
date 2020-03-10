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
  instance_type     = var.instance_type
  instance_key_name = var.instance_key_name
  instance_subnet   = module.network.public_subnet_id
}

module "app" {
  source = "./modules/ami"
  instance_ami      = var.app_ami
  instance_type     = var.instance_type
  instance_key_name = var.instance_key_name
  instance_subnet   = module.network.public_subnet_id
}