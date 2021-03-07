resource "aws_s3_bucket" "customer_bucket" {
  bucket        = "${local.prefix.value}-customer-bucket"
  force_destroy = false

  lifecycle_rule {
    id      = "dump"
    enabled = true

    prefix = "dump/"

    tags = {
      rule      = "log"
      autoclean = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.my_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name = "${local.prefix.value}-customer-bucket"
  }

}


resource "aws_s3_bucket_policy" "customer_bucket_policy" {
  bucket = aws_s3_bucket.customer_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "my_policy"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.customer_bucket.arn,
          "${aws_s3_bucket.customer_bucket.arn}/*",
        ]
        Condition = {
          IPAddress = {
            "aws:SourceIp" = "64.40.11.1/32"
          }
        }
      },
    ]
  })
}


