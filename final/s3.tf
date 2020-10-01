resource "aws_s3_bucket" "my_bucket" {
  bucket = "awsgroupbucket"
  versioning {
    enabled = false
  }
}

//artifacts
resource "aws_s3_bucket_object" "public_artifact" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "calc-0.0.1-SNAPSHOT"
  source = "artifacts/calc-0.0.1-SNAPSHOT.jar"
  etag = filemd5("${path.module}/artifacts/calc-0.0.1-SNAPSHOT.jar")
}

resource "aws_s3_bucket_object" "private_artifact" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "persist3-0.0.1-SNAPSHOT"
  source = "artifacts/persist3-0.0.1-SNAPSHOT.jar"
  etag = filemd5("${path.module}/artifacts/persist3-0.0.1-SNAPSHOT.jar")
}

