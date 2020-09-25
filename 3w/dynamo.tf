resource "aws_dynamodb_table" "access-list" {
  name = "access-list"
  read_capacity = 5
  write_capacity = 5
  hash_key = "name"
  range_key = "lvl"

  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "lvl"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }
}

locals {
  dynamo-db-init = <<EOF
  #!/bin/bash -xe
export PATH=$PATH:/usr/local/bin
/usr/bin/aws configure set default.region us-west-2
/usr/bin/aws dynamodb put-item --table-name access-list --item '{"name": {"S": "yehor"},"lvl": {"S": "root"}}'
/usr/bin/aws dynamodb scan --table-name  access-list > /var/log/dynamo-results.log
EOF

}
resource "aws_s3_bucket_object" "dunamo_db_init_script" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "dynamo-init"
  content = local.dynamo-db-init
}