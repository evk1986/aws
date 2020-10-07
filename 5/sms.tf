data "aws_iam_policy_document" "assume_role" {
  statement {
    actions    = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "publish" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.sns_topic.arn]
  }
}

resource "aws_iam_policy" "publish" {
  name        = var.policy_name
  path        = var.policy_path
  description = "Allow publishing to Group SMS SNS Topic"
  policy      = data.aws_iam_policy_document.publish.json
}

resource "aws_sns_sms_preferences" "sms_preferences" {
  default_sender_id                     = var.default_sender_id
  default_sms_type                      = var.default_sms_type
  delivery_status_success_sampling_rate = var.delivery_status_success_sampling_rate
  monthly_spend_limit                   = var.monthly_spend_limit
}

resource "aws_sns_topic_subscription" "subscription" {
  count     = length(var.subscriptions)
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "sms"
  endpoint  = element(var.subscriptions, count.index)
}