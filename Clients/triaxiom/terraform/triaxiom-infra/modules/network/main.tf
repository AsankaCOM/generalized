locals {
    default_tags = {
        Environment = terraform.workspace
        Name        = "${var.identifier}-${terraform.workspace}"
        }

    tags         = merge(local.default_tags, var.tags)
}

resource "aws_vpc" "vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  cidr_block           = var.cidr

  tags                 = local.tags
}

resource "aws_subnet" "public_subnets" {
  count = length(var.availability_zones)

  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(
    var.cidr,
    ceil(log(length(var.availability_zones) * 2, 2)),
    count.index,
  )

  tags = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public-${count.index}" })
}

resource "aws_subnet" "private_subnets" {
  count = length(var.availability_zones)

  map_public_ip_on_launch = false
  availability_zone       = element(var.availability_zones, count.index)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(
    var.cidr,
    ceil(log(length(var.availability_zones) * 2, 2)),
    length(var.availability_zones) + count.index,
  )

  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-private-${count.index}" })

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags   = local.tags
}

resource "aws_eip" "nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.public_subnets[0].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags  = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public" })

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.nat_gw.id
    cidr_block     = "0.0.0.0/0"
  }

  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-private" })
}

resource "aws_route_table_association" "private_subnet" {
  count          = length(var.availability_zones)

  route_table_id = aws_route_table.private.id
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
}

resource "aws_route_table_association" "public_subnet" {
  count          = length(var.availability_zones)

  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}


resource "aws_vpc_endpoint" "s3" {
  route_table_ids = [ aws_route_table.public.id , aws_route_table.private.id ]
  service_name    = "com.amazonaws.${var.region}.s3"
  vpc_id          = aws_vpc.vpc.id

  tags            = local.tags
}

resource "aws_security_group" "endpoint_sg" {
  description = "endpoint sg security group"    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.identifier}-${terraform.workspace}"
      
  ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
      protocol    = "-1"

  }
      
  egress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
  }
    
  tags        = local.tags
}
