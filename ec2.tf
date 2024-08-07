################################################################################
# EC2 Module
################################################################################

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "ec2-${var.resource_prefix}"
  ami                         = data.aws_ami.redhat_ami.id
  
  ec2_key_pair                    = var.key_name
  ebs_kms_key_arn = aws_kms_key.ebs_key.arn
  
  ec2_instance_type               = "t2.micro"
  vpc_id = module.vpc.vpc_id
  
  subnet_ids                   = [module.vpc.public_subnets[1]]
  
  iam_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.id
  add_SSMManagedInstanceCore = false
  # additional_security_groups = [module.ec2_sg.id]
  associate_public_ip = true
  ebs_optimized = false

  # Storage
  root_volume_size = "20"

   # Security Group Rules
    ingress_rules = {
    "https" = {
      ip_protocol = "tcp"
      from_port   = "443"
      to_port     = "443"
      cidr_ipv4   = var.vpc_cidr
      description = "https"
    },
    "ssh" = {
      ip_protocol = "tcp"
      from_port   = "22"
      to_port     = "22"
      cidr_ipv4   = var.myip
      description = "ssh"
    }
  }

  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }

  # Tagging
  global_tags = {}
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_log_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

resource "aws_ssm_parameter" "ec2_module_key_parameter" {
  name        = "/test/${var.key_name}.pem"
  description = "Private key for EC2 module test build"
  type        = "SecureString"
  value       = data.local_file.key.content
}

resource "aws_kms_key" "ebs_key" {
  description         = "ebs key for ec2-module"
  policy              = data.aws_iam_policy_document.ebs_key.json
  enable_key_rotation = true
}