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

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
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