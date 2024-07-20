data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

# Requires a .pem file exists in this directory. This should be a generated key-pair (example in README)
data "local_file" "key" {
  filename = "${var.key_name}.pem"
}

# EBS key policy
data "aws_iam_policy_document" "ebs_key" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:${local.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}

# AMI
data "aws_ami" "redhat_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # Red Hat owner ID
}

# Policy for Read Access to the images bucket
data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.images_s3_bucket.s3_bucket_arn}/*"]
    effect    = "Allow"
  }
}

# Policy for write access to the logs bucket
data "aws_iam_policy_document" "s3_write_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "${module.log_bucket.s3_bucket_arn}/*",
      "arn:aws:logs:*:*:*"
    ]
    effect = "Allow"
  }
}

# Bucket Policy for images bucket
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${module.images_s3_bucket.s3_bucket_arn}",
    ]
  }
}

# Policy for cloudwatch key
# data "aws_iam_policy_document" "cloudwatch_key" {

#   statement {
#     sid    = "Allow use of the key"
#     effect = "Allow"
#     actions = [
#       "kms:*"
#     ]
#     principals {
#       identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
#       type        = "AWS"
#     }
#     resources = ["*"]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#     ]
#     resources = [
#     "*"]

#     principals {
#       type = "Service"
#       identifiers = [
#       "delivery.logs.amazonaws.com"]
#     }
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#     ]
#     resources = [
#     "*"]

#     principals {
#       type = "Service"
#       identifiers = [
#       "firehose.amazonaws.com"]
#     }
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#     ]
#     resources = [
#     "*"]

#     principals {
#       type = "Service"
#       identifiers = [
#       "logs.${var.aws_region}.amazonaws.com"]
#     }
#   }


#   statement {
#     sid    = "Allow attachment of persistent resources"
#     effect = "Allow"
#     actions = [
#       "kms:CreateGrant",
#       "kms:ListGrants",
#       "kms:RevokeGrant"
#     ]
#     principals {
#       identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
#       type        = "AWS"
#     }
#     resources = ["*"]
#     condition {
#       test     = "Bool"
#       variable = "kms:GrantIsForAWSResource"
#       values   = [true]
#     }
#   }
# }