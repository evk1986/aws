resource "aws_sqs_queue" "queue" {
  name = "edu-lohika-training-aws-sqs-queue"
  tags = {
    Name = "message-broker"
  }
}

resource "aws_sns_topic" "sns_topic" {
  name = "edu-lohika-training-aws-sns-topic"
  tags = {
    Name = "message-broker"
  }
}