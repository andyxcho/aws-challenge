# module "subnet_addrs" {
#   source  = "hashicorp/subnets/cidr"
#   version = "v1.0.0"

#   base_cidr_block = var.vpc_cidr
#   networks = [
#     {
#       name     = "${var.resource_prefix}-public-1a"
#       new_bits = 8
#     },
#     {
#       name     = "${var.resource_prefix}-public-1b"
#       new_bits = 8
#     },
#     {
#       name     = "${var.resource_prefix}-private-1a"
#       new_bits = 8
#     },
#     {
#       name     = "${var.resource_prefix}-private-1b"
#       new_bits = 8
#     }
#   ]
# }