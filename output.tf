output "ids" {
  value       = [for _, v in aws_subnet.this : v.id]
  description = "List of subnet ids"
}

output "cidrs" {
  value       = [for _, v in aws_subnet.this : v.cidr_block]
  description = "List of subnet CIDR blocks"
}

output "rtb_id" {
  value       = var.create_rtb ? join(",", aws_route_table.this.*.id) : var.rtb_id
  description = "ID of route table associated with subnets"
}

output "natgw_id" {
  value       = var.create_rtb && var.create_nat ? join(",", aws_nat_gateway.this.*.id) : var.natgw_id
  description = "ID of NAT gateway associated to the route table"
}

output "natgw_eip" {
  value       = var.create_rtb && var.create_nat ? join(",", aws_eip.nat.*.id) : null
  description = "Elastic IP associated to the NAT gateway"
}

output "nacl_id" {
  value       = aws_network_acl.this.id
  description = "ID of network ACL associated with subnets"
}
