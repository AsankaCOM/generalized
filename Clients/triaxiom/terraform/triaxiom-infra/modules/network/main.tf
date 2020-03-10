#
# AWS VPC setup
#
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = var.identifier
  }
}

#
# AWS Subnets setup
#
resource "aws_subnet" "public_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zones, count.index)
  cidr_block = cidrsubnet(
    var.cidr,
    ceil(log(length(var.availability_zones) * 2, 2)),
    count.index,
  )
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.identifier}-Public-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zones, count.index)
  cidr_block = cidrsubnet(
    var.cidr,
    ceil(log(length(var.availability_zones) * 2, 2)),
    length(var.availability_zones) + count.index,
  )
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.identifier}-Private-${count.index}"
  }
}

#
# AWS IGW setup
#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.identifier}-igw"
  }
}

#
# AWS Nat Gateway setyp
# Used for the private subnets
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

  tags = {
    Name = "${var.identifier}-Public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.identifier}-Private"
  }
}

resource "aws_route_table_association" "private_subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [ aws_route_table.public.id , aws_route_table.private.id ]
  tags = {
    Name = var.identifier
  }
}

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint-sg"
  description = "endpoint sg security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
