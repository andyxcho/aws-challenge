variable "aws_region" {
  description = "The region where things will be deployed by default"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "The name of the EC2 pem key in this directory (without the suffix)"
  type        = string
}

variable "vpc_cidr" {
  description = "The cidr block for the vpc created for testing the security group"
  type        = string
}

variable "public_subnets" {
  description = "List for the public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List for the private subnets"
  type        = list(string)
}

variable "certificate_arn" {
  description = "Certificate arn"
  type        = string
}

variable "myip" {
  description = "Personal IP address (ex: x.x.x.x/32)"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to add to resources"
  type        = string
  default = "demo"
}