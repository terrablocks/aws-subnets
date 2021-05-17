# Create subnets for your existing VPC

![License](https://img.shields.io/github/license/terrablocks/aws-subnets?style=for-the-badge) ![Tests](https://img.shields.io/github/workflow/status/terrablocks/aws-subnets/tests/master?label=Test&style=for-the-badge) ![Checkov](https://img.shields.io/github/workflow/status/terrablocks/aws-subnets/checkov/master?label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/aws-subnets?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/aws-subnets?style=for-the-badge)

This terraform module will deploy the following services:
- Subnets
- NAT Gateway (Optional)
- Route Table (Optional)
- NACL

# Usage Instructions
## Example
```terraform
module "subnet" {
  source = "github.com/terrablocks/aws-subnets.git"

  vpc_id = "vpc-xxxx"
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
| azs | List of availability zones to be used for creating subnets | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b"<br>]</pre> | no |
| vpc_id | ID of VPC to associate resource with | `string` | n/a | yes |
| cidr_block | VPC CIDR block to use as a base for assigning CIDR to subnet. Leave it blank to use the default CIDR block | `string` | `""` | no |
| subnet_index | Nth network within a CIDR to use as the starting point for subnet CIDR or count of existing subnets in VPC. 0 means no subnets exist within the VPC CIDR block | `number` | `0` | no |
| subnet_name | Name of subnet | `string` | `""` | no |
| map_public_ip | Automatically assign public ip to resources launched in this subnet | `bool` | `false` | no |
| mask | Subnet mask to assign to subnet | `number` | `26` | no |
| create_rtb | Create route table for the subnet and associate it | `bool` | `true` | no |
| rtb_name | Name for route table to be created if `create_rtb` is set to true | `string` | `null` | no |
| rtb_id | Existing route table to associate with subnet. **Note:** Required only if `create_rtb` is set to false | `string` | `""` | no |
| igw_id | Internet gateway id to assicate with route table | `string` | `""` | no |
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
