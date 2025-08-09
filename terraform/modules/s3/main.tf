locals {
  tags = {
    project     = var.project
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}


resource "aws_s3_bucket" "backup" {
  bucket = "aj3-aws-infra-backup-${random_id.suffix.hex}"

  tags = merge(
      local.tags,
      {
        Name = "EC2BackupBucket"
      }
  )

}

# # S3 bucket ACL (private)
# resource "aws_s3_bucket_acl" "backup" {
#   bucket = aws_s3_bucket.backup.id
#   acl    = "private"
# }

# 2. Object ownership: disable ACLs (Bucket owner enforced)
resource "aws_s3_bucket_ownership_controls" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 3. Block toàn bộ public access
resource "aws_s3_bucket_public_access_block" "backup" {
  bucket                  = aws_s3_bucket.backup.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# 4. IAM Role cho EC2 (để EC2 có quyền ghi vào S3)
resource "aws_iam_role" "ec2_role" {
  name = "ec2-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# 5. Policy cho phép ghi vào bucket
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "ec2-backup-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.backup.arn,
          "${aws_s3_bucket.backup.arn}/*"
        ]
      }
    ]
  })
}


# 6. Bucket policy cho phép IAM Role ghi dữ liệu
resource "aws_s3_bucket_policy" "backup" {
  bucket = aws_s3_bucket.backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEC2RoleWrite"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action    = ["s3:PutObject", "s3:ListBucket"]
        Resource  = [
          aws_s3_bucket.backup.arn,
          "${aws_s3_bucket.backup.arn}/*"
        ]
      }
    ]
  })
}


# 7. Bật versioning để giữ các bản cũ
resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id

  versioning_configuration {
    status = "Enabled"
  }
}


# 8. Bật mã hóa dữ liệu at rest (SSE-S3)
# Nếu bạn muốn SSE-KMS, thay "AES256" bằng "aws:kms"
resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# 9. Lifecycle policy để chuyển dữ liệu sang Glacier
# Ví dụ: sau 30 ngày chuyển sang Glacier Flexible Retrieval
resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "MoveOldObjectsToGlacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    # Optional: Expire permanently sau 365 ngày
    expiration {
      days = 365
    }
  }
}