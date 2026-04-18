# IAM Role for Data Ingestion (can only WRITE to raw zone)
resource "aws_iam_role" "ingestion_role" {
  name = "ingestion-role-demo"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ingestion_policy" {
  name = "ingestion-policy"
  role = aws_iam_role.ingestion_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.raw_zone.arn,
          "${aws_s3_bucket.raw_zone.arn}/*"
        ]
      },
      {
        Effect = "Deny"
        Action = ["s3:GetObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.raw_zone.arn}/*"
      }
    ]
  })
}

# IAM Role for ETL (can read raw, write to processed)
resource "aws_iam_role" "etl_role" {
  name = "etl-role-demo"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "elasticmapreduce.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "etl_policy" {
  name = "etl-policy"
  role = aws_iam_role.etl_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.raw_zone.arn}/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject"]
        Resource = "${aws_s3_bucket.processed_zone.arn}/*"
      }
    ]
  })
}

# IAM Role for Analyst (can ONLY read curated zone)
resource "aws_iam_role" "analyst_role" {
  name = "analyst-role-demo"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
    }]
  })
}

resource "aws_iam_role_policy" "analyst_policy" {
  name = "analyst-policy"
  role = aws_iam_role.analyst_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.curated_zone.arn,
          "${aws_s3_bucket.curated_zone.arn}/*"
        ]
      },
      {
        Effect = "Deny"
        Action = ["s3:GetObject", "s3:ListBucket", "s3:PutObject", "s3:DeleteObject"]
        Resource = [
          aws_s3_bucket.raw_zone.arn,
          "${aws_s3_bucket.raw_zone.arn}/*",
          aws_s3_bucket.processed_zone.arn,
          "${aws_s3_bucket.processed_zone.arn}/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

output "ingestion_role_arn" {
  value = aws_iam_role.ingestion_role.arn
}

output "etl_role_arn" {
  value = aws_iam_role.etl_role.arn
}

output "analyst_role_arn" {
  value = aws_iam_role.analyst_role.arn
}