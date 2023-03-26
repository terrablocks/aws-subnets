data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_internet_gateway" "this" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

resource "aws_subnet" "this" {
  # checkov:skip=CKV_AWS_130: Enabling public IP for subnet depends on user
  for_each                = var.cidr_blocks
  vpc_id                  = data.aws_vpc.this.id
  map_public_ip_on_launch = var.map_public_ip
  cidr_block              = each.value
  availability_zone       = each.key

  tags = merge({
    Name = "${var.subnet_name}-${split("-", each.key)[2]}"
    Zone = each.key
  }, var.tags)

  lifecycle {
    # Ignore tags added by kubernetes
    ignore_changes = [tags.kubernetes]
  }
}

resource "aws_route_table" "this" {
  count  = var.create_rtb ? 1 : 0
  vpc_id = data.aws_vpc.this.id

  tags = merge({
    Name = var.rtb_name
  }, var.tags)
}

resource "aws_route" "igw" {
  count                  = var.create_rtb && var.attach_igw ? 1 : 0
  route_table_id         = join(",", aws_route_table.this.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.this.internet_gateway_id
}

resource "aws_eip" "nat" {
  # checkov:skip=CKV2_AWS_19: EIP is associated with NAT gateway
  count = var.create_nat && var.nat_eip_id == "" ? 1 : 0
  vpc   = true

  tags = merge({
    Name = "${var.subnet_name}-nat-eip"
  }, var.tags)
}

resource "aws_nat_gateway" "this" {
  count         = var.create_nat ? 1 : 0
  subnet_id     = var.natgw_subnet_id
  allocation_id = var.nat_eip_id == "" ? join(", ", aws_eip.nat.*.id) : var.nat_eip_id

  tags = merge({
    Name = "${var.subnet_name}-nat"
  }, var.tags)
}

resource "aws_route" "ngw" {
  count                  = var.create_rtb && (var.create_nat || var.natgw_id != null) ? 1 : 0
  route_table_id         = join(",", aws_route_table.this.*.id)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.create_nat ? join(",", aws_nat_gateway.this.*.id) : var.natgw_id
}

resource "aws_route_table_association" "this" {
  for_each       = var.cidr_blocks
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = var.create_rtb ? join(",", aws_route_table.this.*.id) : var.rtb_id
}

resource "aws_network_acl" "this" {
  vpc_id     = data.aws_vpc.this.id
  subnet_ids = [for _, v in aws_subnet.this : v.id]

  dynamic "ingress" {
    for_each = var.nacl_ingress_rules
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.nacl_egress_rules
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = var.tags
}
