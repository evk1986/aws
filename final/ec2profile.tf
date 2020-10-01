
resource "aws_iam_policy" "s3_policy" {
  name        = "ec2--s3-policy"
  description = "s3 access"
  policy      = file("policies/s3Policy.json")
}

resource "aws_iam_policy" "rds_policy" {
  name        = "ec2-rds-policy"
  description = "rds acess"
  policy      = file("policies/rdsPolicy.json")
}

resource "aws_iam_policy" "dynamo_policy" {
  name        = "ec2-dynamo-policy"
  description = "dynamo"
  policy      = file("policies/dynamoPolicy.json")
}

resource "aws_iam_policy" "sqs" {
  name        = "ec2-sqs-policy"
  description = "sqs"
  policy      = file("policies/sqsPolicy.json")
}

resource "aws_iam_policy" "sns" {
  name        = "ec2-sns-policy"
  description = "sns"
  policy      = file("policies/snsPolicy.json")
}

resource "aws_iam_role" "assume_role" {
  name               = "root-role"
  assume_role_policy = file("policies/assumePolicyRole.json")
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

resource "aws_iam_policy_attachment" "attachment_sqs" {
  name       = "ec2-attachment"
  roles      = [aws_iam_role.assume_role.name]
  policy_arn = aws_iam_policy.sqs.arn
}

resource "aws_iam_policy_attachment" "attachment_sns" {
  name       = "ec2-attachment"
  roles      = [aws_iam_role.assume_role.name]
  policy_arn = aws_iam_policy.sns.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name  = "ec2_profile"
  role = aws_iam_role.assume_role.name
}

