locals {
  account_id      = data.aws_caller_identity.current.account_id
  partition       = data.aws_partition.current.partition
#   public_subnets  = [for k, v in module.subnet_addrs.network_cidr_blocks : v if length(regexall(".*public.*", k)) > 0]
#   private_subnets = [for k, v in module.subnet_addrs.network_cidr_blocks : v if(length(regexall(".*priv.*", k)) > 0 || length(regexall(".*compute.*", k)) > 0)]
}