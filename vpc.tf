################################################################################
# VPC
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "demo-vpc"
  cidr = var.vpc_cidr

  azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = false
  single_nat_gateway = false
  one_nat_gateway_per_az = false
  create_igw         = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  vpc_flow_log_iam_role_name            = "vpc-complete-example-role"
  vpc_flow_log_iam_role_use_name_prefix = false
  enable_flow_log                       = true
  create_flow_log_cloudwatch_log_group  = true
  create_flow_log_cloudwatch_iam_role   = true
  flow_log_max_aggregation_interval     = 60

  tags = {}
}

# module "vpc" {
#   source = "github.com/Coalfire-CF/terraform-aws-vpc-nfw"

#   name = "vpc-demo"

#   delete_protection = false

#   cidr = var.vpc_cidr

#   azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]

#   private_subnets = local.private_subnets
#   private_subnet_tags = {
#     "0" = "Private"
#     "1" = "Private"
#   }


#   public_subnets       = local.public_subnets
#   public_subnet_suffix = "public"

#   create_database_subnet_group = false
#   single_nat_gateway           = false
#   enable_nat_gateway           = true
#   one_nat_gateway_per_az       = true
#   enable_vpn_gateway           = false
#   enable_dns_hostnames         = true

#   flow_log_destination_type              = "cloud-watch-logs"
#   cloudwatch_log_group_retention_in_days = 30
#   cloudwatch_log_group_kms_key_id        = aws_kms_key.cloudwatch_key.arn

#   /* Add Additional tags here */
#   tags = {
#     createdBy = "terraform"
#   }
# }