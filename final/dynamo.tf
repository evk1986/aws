resource "aws_dynamodb_table" "access-list" {
  name = "edu-lohika-training-aws-dynamodb"
  read_capacity = 5
  write_capacity = 5
  hash_key = "UserName"

  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "UserName"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
}