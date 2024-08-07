################################################################################
# App Load Balancer
################################################################################
resource "aws_lb" "asg_lb" {
  name               = "alb-demo"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.id]
  subnets            = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true

  #   access_logs {
  #     bucket  = module.s3_bucket_logs.id
  #     prefix  = "asg-lb"
  #     enabled = true
  #   }

  tags = {
    Name = "asg-lb"
  }
}

# Create the target group for the ASG
resource "aws_lb_target_group" "asg_tg" {
  name     = "asg-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "asg-tg"
  }
}

# Create the ALB listener for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.asg_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create the ALB listener for HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.asg_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
}

################################################################################
# Supporting Resources
################################################################################
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name        = "alb-sg"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    "allow_http" = {
      ip_protocol = "tcp"
      from_port   = "80"
      to_port     = "80"
      cidr_ipv4   = "0.0.0.0/0"
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
