provider "aws" {
    region = "us-west-2"
}
module "network" {
  source = "./modules/network"
  cidr = "${var.cidr}"
  availability_zones = "${var.availability_zones}"
  region = "${var.region}"
}
