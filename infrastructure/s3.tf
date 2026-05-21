resource "aws_s3_bucket" "raw_bucket" {
  bucket = "sn-raw-data-sl-${var.environment}"
}

resource "aws_s3_bucket" "bronze_bucket" {
  bucket = "sn-bronze-data-sl-${var.environment}"
}

resource "aws_s3_bucket" "meta_bucket" {
  bucket = "sn-meta-data-sl-${var.environment}"
}

locals {
  bucket_map = {
    raw    = aws_s3_bucket.raw_bucket.id
    bronze = aws_s3_bucket.bronze_bucket.id
    meta   = aws_s3_bucket.meta_bucket.id
  }
}

resource "aws_s3_bucket_public_access_block" "all_buckets" {
  for_each                = local.bucket_map
  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = local.bucket_map
  bucket   = each.value
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "meta_versioning" {
  bucket = aws_s3_bucket.meta_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}