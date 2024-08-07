################################################################################
# S3 Buckets
################################################################################
resource "random_id" "this" {
  byte_length = 4
}

module "log_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "logs-${random_id.this.hex}"
  force_destroy = true

  control_object_ownership = true

  lifecycle_rule = [
    {
      id      = "inactive"
      enabled = true

      filter = {
        prefix = "inactive/"
      }

      expiration = {
        days = 90
      }
    },
    {
      id      = "active"
      enabled = true

      filter = {
        prefix = "active/"
      }

      transition = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}

module "images_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "images-${random_id.this.hex}"
  force_destroy = true


  tags = {}

  control_object_ownership = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "memes"
      enabled = true

      filter = {
        prefix = "memes/"
      }

      transition = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_s3_object" "archive" {
  bucket = module.images_s3_bucket.s3_bucket_id
  key    = "archive/"
}

resource "aws_s3_object" "memes" {
  bucket = module.images_s3_bucket.s3_bucket_id
  key    = "memes/"
}

resource "aws_s3_object" "active" {
  bucket = module.log_bucket.s3_bucket_id
  key    = "active/"
}

resource "aws_s3_object" "inactive" {
  bucket = module.log_bucket.s3_bucket_id
  key    = "inactive/"
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}