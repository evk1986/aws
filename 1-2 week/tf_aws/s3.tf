resource "aws_s3_bucket" "my_bucket" {
  bucket = "awsgroupbucket"
  versioning {
    enabled = true
  }
}

//artifacts
resource "aws_s3_bucket_object" "text_file" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "text"
  source = "text.txt"
  etag = filemd5("${path.module}/text.txt")
}
