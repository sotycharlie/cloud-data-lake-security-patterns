# KMS key for restricted data (per-object encryption)
resource "aws_kms_key" "restricted_key" {
  description             = "KMS key for data lake restricted zone"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# KMS alias for easy reference
resource "aws_kms_alias" "restricted_key_alias" {
  name          = "alias/data-lake-restricted"
  target_key_id = aws_kms_key.restricted_key.key_id
}

# Apply KMS encryption to raw bucket (per-object unique keys)
resource "aws_s3_bucket_server_side_encryption_configuration" "raw_kms" {
  bucket = aws_s3_bucket.raw_zone.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.restricted_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Apply KMS encryption to processed bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "processed_kms" {
  bucket = aws_s3_bucket.processed_zone.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.restricted_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Apply KMS encryption to curated bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "curated_kms" {
  bucket = aws_s3_bucket.curated_zone.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.restricted_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

output "kms_key_arn" {
  value = aws_kms_key.restricted_key.arn
}

output "kms_key_id" {
  value = aws_kms_key.restricted_key.key_id
}