terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "raw_zone" {
  bucket = "data-lake-raw-${random_id.suffix.hex}"
  
  tags = {
    Name        = "Data Lake Raw Zone"
    Environment = "Research"
  }
}

resource "aws_s3_bucket" "processed_zone" {
  bucket = "data-lake-processed-${random_id.suffix.hex}"
  
  tags = {
    Name        = "Data Lake Processed Zone"
    Environment = "Research"
  }
}

resource "aws_s3_bucket" "curated_zone" {
  bucket = "data-lake-curated-${random_id.suffix.hex}"
  
  tags = {
    Name        = "Data Lake Curated Zone"
    Environment = "Research"
  }
}

resource "aws_s3_bucket_public_access_block" "raw_block" {
  bucket = aws_s3_bucket.raw_zone.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "processed_block" {
  bucket = aws_s3_bucket.processed_zone.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "curated_block" {
  bucket = aws_s3_bucket.curated_zone.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_encrypt" {
  bucket = aws_s3_bucket.raw_zone.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_encrypt" {
  bucket = aws_s3_bucket.processed_zone.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated_encrypt" {
  bucket = aws_s3_bucket.curated_zone.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "raw_bucket_name" {
  value = aws_s3_bucket.raw_zone.id
}

output "processed_bucket_name" {
  value = aws_s3_bucket.processed_zone.id
}

output "curated_bucket_name" {
  value = aws_s3_bucket.curated_zone.id
}