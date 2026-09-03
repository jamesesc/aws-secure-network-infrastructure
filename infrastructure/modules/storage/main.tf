# Creating the S3 bucket for this VPC
resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-first-ever-s3-bucket-cloud-project-2026"

    tags = {
        Name = "My bucket"
        Environment = "Dev"
    }
}

# Modern apporach to securely manage S3 buckets for controls
resource "aws_s3_bucket_ownership_controls" "my_bucket_ownership_controls" {
    bucket = aws_s3_bucket.my_bucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# Block the public access to our S3 Bucket
resource "aws_s3_bucket_public_access_block" "my_bucket_public_access_block" {
    bucket = aws_s3_bucket.my_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# Handles the S3 bucket access control list (aka ACL) 
resource "aws_s3_bucket_acl" "my_bucket_acl" {
    depends_on = [aws_s3_bucket_ownership_controls.my_bucket_ownership_controls]
    
    bucket = aws_s3_bucket.my_bucket.id
    acl = "private"
}

# Handles the S3 bucket versioning
resource "aws_s3_bucket_versioning" "s3_versioning" {
    bucket = aws_s3_bucket.my_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

# Handles the S3 security
resource "aws_kms_key" "s3_kms_key" {
    description = "this key is used to encrypt the S3 bucket objects"
    deletion_window_in_days = 10
}

# Handles the S3 bucket server side encryption config
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
    bucket = aws_s3_bucket.my_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id = aws_kms_key.s3_kms_key.arn
            sse_algorithm = "aws:kms"
        }
    }
}