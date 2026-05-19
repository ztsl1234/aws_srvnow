
# 1. Raw Bucket: The "Drop Zone"
resource "aws_s3_bucket" "raw_bucket" {
  bucket = "sn-raw-data-tsl"
}

# 2. Bronze Bucket: The Partitioned/Processed Layer
resource "aws_s3_bucket" "bronze_bucket" {
  bucket = "sn-bronze-data-tsl"
}

# 3. Meta Bucket: Stores your Scripts, Libs, and Configs
resource "aws_s3_bucket" "meta_bucket" {
  bucket = "sn-meta-data-tsl"
}

# --- Standard Security: Enable Versioning for Meta/Scripts ---
resource "aws_s3_bucket_versioning" "meta_versioning" {
  bucket = aws_s3_bucket.meta_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- Block Public Access (Required for Enterprise compliance) ---
resource "aws_s3_bucket_public_access_block" "all_buckets" {
  for_each = toset([
    aws_s3_bucket.raw_bucket.id,
    aws_s3_bucket.bronze_bucket.id,
    aws_s3_bucket.meta_bucket.id
  ])

  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Server-Side Encryption (Best Practice) ---
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = toset([
    aws_s3_bucket.raw_bucket.id,
    aws_s3_bucket.bronze_bucket.id,
    aws_s3_bucket.meta_bucket.id
  ])
  bucket = each.value
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}