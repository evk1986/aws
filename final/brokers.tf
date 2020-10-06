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

resource "aws_sqs_queue" "subscription_queue" {
  name = "notifications"
  tags = {
    Name = "result-listener"
  }
}

resource "aws_sns_topic_subscription" "results_updates_sqs_target" {
  topic_arn = aws_sns_topic.sns_topic.arn
  endpoint  = aws_sqs_queue.subscription_queue.arn
  protocol  = "sqs"
}