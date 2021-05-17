data "aws_vpc" "this" {
  id = var.vpc_id
}

locals {
  vpc_cidr = var.cidr_block == "" ? data.aws_vpc.this.cidr_block : var.cidr_block
  vpc_mask = element(split("/", local.vpc_cidr), 1)
}

resource "aws_subnet" "this" {
  # checkov:skip=CKV_AWS_130: Enabling public IP for subnet depends on user
  count                   = length(var.azs)
  vpc_id                  = data.aws_vpc.this.id
  map_public_ip_on_launch = var.map_public_ip
  cidr_block = cidrsubnet(
    local.vpc_cidr,
    var.mask - local.vpc_mask,
    count.index + var.subnet_index,
  )
  availability_zone = element(var.azs, count.index)

  tags = merge({
    Name = var.subnet_name
    Zone = element(var.azs, count.index)
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
  count                  = var.create_rtb && var.igw_id != "" ? 1 : 0
  route_table_id         = join(",", aws_route_table.this.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_eip" "nat" {
  # checkov:skip=CKV2_AWS_19: EIP is associated with NAT gateway
  count = var.create_rtb && var.create_nat ? 1 : 0
  vpc   = true
  tags  = var.tags
}

resource "aws_nat_gateway" "this" {
  count         = var.create_rtb && var.create_nat ? 1 : 0
  subnet_id     = var.natgw_subnet_id
  allocation_id = join(", ", aws_eip.nat.*.id)
  tags          = var.tags
}

resource "aws_route" "ngw" {
  count                  = var.create_rtb && (var.create_nat || var.natgw_id != null) ? 1 : 0
  route_table_id         = join(",", aws_route_table.this.*.id)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.create_nat ? join(",", aws_nat_gateway.this.*.id) : var.natgw_id
}

resource "aws_route_table_association" "this" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = var.create_rtb ? join(",", aws_route_table.this.*.id) : var.rtb_id
}

resource "aws_network_acl" "this" {
  vpc_id     = data.aws_vpc.this.id
  subnet_ids = aws_subnet.this.*.id

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
