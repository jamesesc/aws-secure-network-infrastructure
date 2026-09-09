# The S3 Bucket that is dedicated in storing our terraform state files
resource "aws_s3_bucket" "terraform_s3_bucket" {
    bucket = "my-first-ever-s3-terrform-state-bucket-cloud-project-2026"

    tags = {
        Name = "Terraform State S3 Bucket"
        Environment = "Dev"
    }

    lifecycle {
      prevent_destroy = true
    }
}

# The S3 Ownership
resource "aws_s3_bucket_ownership_controls" "terraform_bucket_ownership_controls" {
    bucket = aws_s3_bucket.terraform_s3_bucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# S3 Public Access Blockage
resource "aws_s3_bucket_public_access_block" "terraform_bucket_public_access" {
    bucket = aws_s3_bucket.terraform_s3_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# Handling S3 Bucket SCL to be private
resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
    depends_on = [aws_s3_bucket_ownership_controls.terraform_bucket_ownership_controls ]

    bucket = aws_s3_bucket.terraform_s3_bucket.id
    acl = "private"
}

# Allowing S3 Bucket with versioning
resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
    bucket = aws_s3_bucket.terraform_s3_bucket.id

    versioning_configuration {
      status = "Enabled"
    }
}

# The KMS key for the S3
resource "aws_kms_key" "s3_kms_key" {
    description = "This is the kms setup to securely encrypt our S3 Terraform Bucket"
    deletion_window_in_days = 10
}

# S3 Encryptiong Setting
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_s3_encryption" {
    bucket = aws_s3_bucket.terraform_s3_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = aws_kms_key.s3_kms_key.arn
          sse_algorithm = "aws:kms"
        }
    }
}