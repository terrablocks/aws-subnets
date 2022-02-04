variable "vpc_id" {
  type        = string
  description = "ID of VPC to associate resource with"
}

variable "cidr_blocks" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Map of availability zone and cidr block to assign
    ```{
      us-east-1a = "10.0.1.0/24"
      us-east-1b = "10.0.2.0/24"
      us-east-1c = "10.0.3.0/24"
    }```
  EOT
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "Name of subnet"
}

variable "map_public_ip" {
  type        = bool
  default     = false
  description = "Automatically assign public ip to resources launched in this subnet"
}

variable "create_rtb" {
  type        = bool
  default     = true
  description = "Create route table for the subnet and associate it"
}

variable "rtb_name" {
  type        = string
  default     = null
  description = "Name for route table to be created if `create_rtb` is set to true"
}

variable "rtb_id" {
  type        = string
  default     = ""
  description = "Existing route table to associate with subnet. **Note:** Required only if `create_rtb` is set to false"
}

variable "attach_igw" {
  type        = bool
  default     = false
  description = "Whether to attach internet gateway to the route table"
}

variable "create_nat" {
  type        = bool
  default     = false
  description = "Whether to create NAT gateway for subnet and associate it to the route table"
}

variable "natgw_subnet_id" {
  type        = string
  default     = ""
  description = "Subnet ID to place NAT gateway in. **Note:** Required if `create_nat` is set to true"
}

variable "natgw_id" {
  type        = string
  default     = null
  description = "Existing NAT gateway to associate with route table"
}

variable "nacl_ingress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = number
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  ]
  description = "Numbered ingress rules for NACL"
}

variable "nacl_egress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = number
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  default = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
    }
  ]
  description = "Numbered egress rules for NACL"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of key-value pair to associate with resources"
}
