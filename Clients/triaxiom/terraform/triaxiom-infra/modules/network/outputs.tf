output "vpc" {
  value = aws_vpc.vpc
}

output "nat_gw" {
  value = aws_nat_gateway.nat_gw
}

output "public_subnet_id" {
  value = aws_subnet.public_subnets[0].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnets[0].id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "public_rt" {
  value = aws_route_table.public.id
}

output "private_rt" {
  value = aws_route_table.private.id
}
