# Create subnets for your existing VPC

![License](https://img.shields.io/github/license/terrablocks/aws-subnets?style=for-the-badge) ![Tests](https://img.shields.io/github/actions/workflow/status/terrablocks/aws-subnets/tests.yml?branch=main&label=Test&style=for-the-badge) ![Checkov](https://img.shields.io/github/actions/workflow/status/terrablocks/aws-subnets/checkov.yml?branch=main&label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/aws-subnets?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/aws-subnets?style=for-the-badge)

This terraform module will deploy the following services:
- Subnets
- NAT Gateway (Optional)
- Route Table (Optional)
- NACL

# Usage Instructions
## Example
```terraform
module "vpc" {
  source = "github.com/terrablocks/aws-vpc.git"

  network_name = "dev"
}

module "pub_subnet" {
  source = "github.com/terrablocks/aws-subnets.git"

  vpc_id = module.vpc.id
  cidr_blocks = {
    us-east-1a = "10.0.1.0/24"
    us-east-1b = "10.0.2.0/24"
    us-east-1c = "10.0.3.0/24"
  }
  subnet_name   = "public-subnet"
  map_public_ip = true
  rtb_name      = "public-rtb"
  attach_igw    = true
}

module "pvt_subnet" {
  source = "github.com/terrablocks/aws-subnets.git"

  vpc_id = module.vpc.id
  cidr_blocks = {
    us-east-1a = "10.0.4.0/24"
    us-east-1b = "10.0.5.0/24"
    us-east-1c = "10.0.6.0/24"
  }
  subnet_name     = "private-subnet"
  rtb_name        = "private-rtb"
  create_nat      = true
  natgw_subnet_id = module.pub_subnet.ids[0]
}

module "protected_subnet" {
  source = "github.com/terrablocks/aws-subnets.git"

  vpc_id = module.vpc.id
  cidr_blocks = {
    ap-south-1a = "10.0.7.0/24"
    ap-south-1b = "10.0.8.0/24"
    ap-south-1c = "10.0.9.0/24"
  }
  subnet_name = "protected-subnet"
  rtb_name    = "protected-rtb"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.37.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | ID of VPC to associate resource with | `string` | n/a | yes |
| cidr_blocks | Map of availability zone and cidr block to assign<pre>{<br>  us-east-1a = "10.0.1.0/24"<br>  us-east-1b = "10.0.2.0/24"<br>  us-east-1c = "10.0.3.0/24"<br>}</pre> | `map(string)` | `{}` | no |
| subnet_name | Name of subnet | `string` | `""` | no |
| map_public_ip | Automatically assign public ip to resources launched in this subnet | `bool` | `false` | no |
| create_rtb | Create route table for the subnet and associate it | `bool` | `true` | no |
| rtb_name | Name for route table to be created if `create_rtb` is set to true | `string` | `null` | no |
| rtb_id | Existing route table to associate with subnet. **Note:** Required only if `create_rtb` is set to false | `string` | `""` | no |
| attach_igw | Whether to attach internet gateway to the route table | `bool` | `false` | no |
| create_nat | Whether to create NAT gateway for subnet and associate it to the route table | `bool` | `false` | no |
| natgw_subnet_id | Subnet ID to place NAT gateway in. **Note:** Required if `create_nat` is set to true | `string` | `""` | no |
| natgw_id | Existing NAT gateway to associate with route table | `string` | `null` | no |
| nacl_ingress_rules | Numbered ingress rules for NACL | <pre>list(object({<br>    protocol   = string<br>    rule_no    = number<br>    action     = string<br>    cidr_block = string<br>    from_port  = number<br>    to_port    = number<br>  }))</pre> | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| nacl_egress_rules | Numbered egress rules for NACL | <pre>list(object({<br>    protocol   = string<br>    rule_no    = number<br>    action     = string<br>    cidr_block = string<br>    from_port  = number<br>    to_port    = number<br>  }))</pre> | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| tags | Map of key-value pair to associate with resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ids | List of subnet ids |
| cidrs | List of subnet CIDR blocks |
| rtb_id | ID of route table associated with subnets |
| natgw_id | ID of NAT gateway associated to the route table |
| natgw_eip | Elastic IP associated to the NAT gateway |
| nacl_id | ID of network ACL associated with subnets |
