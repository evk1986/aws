
resource "aws_iam_policy" "s3_policy" {
  name        = "ec2--s3-policy"
  description = "s3 acess"
  policy      = file("s3Policy.json")
}

resource "aws_iam_policy" "rds_policy" {
  name        = "ec2-rds-policy"
  description = "rds acess"
  policy      = file("rdsPolicy.json")
}

resource "aws_iam_policy" "dynamo_policy" {
  name        = "ec2-dynamo-policy"
  description = "dynamo"
  policy      = file("dynamoPolicy.json")
}



resource "aws_iam_role" "assume_role" {
  name               = "root-role"
  assume_role_policy = file("assumePolicyRole.json")
}

resource "aws_iam_policy_attachment" "attachment_s3" {
  name       = "ec2-attachment"
  roles      = [aws_iam_role.assume_role.name]
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_policy_attachment" "attachment_rds" {
  name       = "ec2-attachment"
  roles      = [aws_iam_role.assume_role.name]
  policy_arn = aws_iam_policy.rds_policy.arn
}

resource "aws_iam_policy_attachment" "attachment_dynamo" {
  name       = "ec2-attachment"
  roles      = [aws_iam_role.assume_role.name]
  policy_arn = aws_iam_policy.dynamo_policy.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name  = "ec2_profile"
  role = aws_iam_role.assume_role.name
}

