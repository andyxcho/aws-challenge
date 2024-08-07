################################################################################
# AutoScaling Group
################################################################################
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "asg-${var.resource_prefix}"

  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]] # Subnets 3 and 4 (Private subnets)

  # Traffic source attachment
  create_traffic_source_attachment = true
  traffic_source_identifier        = aws_lb_target_group.asg_tg.arn
  traffic_source_type              = "elbv2"


  # Launch template
  launch_template_name        = "asg-lt"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = data.aws_ami.redhat_ami.id
  instance_type     = "t2.micro"
  user_data         = base64encode(file("${path.module}/userdata/httpd.sh"))
  ebs_optimized     = false
  enable_monitoring = true
  key_name          = var.key_name

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "asg-role"
  iam_role_path               = "/ec2/"
  iam_role_description        = "ASG role"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    s3-read-policy               = aws_iam_policy.s3_read_policy.arn
    s3-write-policy              = aws_iam_policy.s3_write_policy.arn
  }

  security_groups = [module.asg_sg.id]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

################################################################################
# Supporting Resources
################################################################################
module "asg_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "asg-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = {
    "allow_https" = {
      ip_protocol = "tcp"
      from_port   = "443"
      to_port     = "443"
      cidr_ipv4   = var.vpc_cidr
    }
    "allow_ssh" = {
      ip_protocol = "tcp" # had to change from protocol to ip_protocol
      from_port   = "22"
      to_port     = "22"
      cidr_ipv4 = var.myip # had to update to cidr_ipv4 and cannot be a list
    }
  }

  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"
  description = "Allow read access to the Images S3 bucket"
  policy      = data.aws_iam_policy_document.s3_read_policy.json
}

resource "aws_iam_policy" "s3_write_policy" {
  name        = "s3-write-policy"
  description = "Allow write access to the Logs S3 bucket"
  policy      = data.aws_iam_policy_document.s3_write_policy.json
}