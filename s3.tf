resource "aws_s3_bucket" "assets" {
  bucket = "whitespace-assets-${var.environment}"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "assets_policy" {
  bucket = aws_s3_bucket.assets.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}
