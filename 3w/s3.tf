resource "aws_s3_bucket" "my_bucket" {
  bucket = "awsgroupbucket"
  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_object" "sql_init" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "rds-init"
  source = "rds-init.sql"
  etag = filemd5("${path.module}/rds-init.sql")
}