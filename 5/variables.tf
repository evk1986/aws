variable "region" {
  default = "us-west-2"
}

variable "profile" {
  default = "default"
}

variable "ami" {
  default = "ami-003d8924a33dc0fd7"
}

variable "ec2_type" {
  default = "t2.nano"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "subnets_cidr" {
  type = map(string)
  default = {
    public = "10.20.2.0/24"
    private = "10.20.1.0/24"
    bastion = "10.20.3.0/24"
  }
}

data "aws_availability_zones" "available" {}


variable "default_sender_id" {
  description = "A custom ID, such as your business brand, displayed as the sender on the receiving device. Support for sender IDs varies by country."
  default     = "aws_group"
}

variable "default_sms_type" {
  description = "Promotional messages are noncritical, such as marketing messages. Transactional messages are delivered with higher reliability to support customer transactions, such as one-time passcodes."
  default     = "Promotional"
}

variable "delivery_status_iam_role_arn" {
  description = "The IAM role that allows Amazon SNS to write logs for SMS deliveries in CloudWatch Logs."
  default     = ""
}

variable "delivery_status_success_sampling_rate" {
  description = "Default percentage of success to sample."
  default     = ""
}

variable "monthly_spend_limit" {
  description = "The maximum amount to spend on SMS messages each month. If you send a message that exceeds your limit, Amazon SNS stops sending messages within minutes."
  default     = 1
}

variable "policy_name" {
  description = "Name of policy to publish to Group SMS topic."
  default     = "group-sms-publish"
}

variable "policy_path" {
  description = "Path of policy to publish to Group SMS topic"
  default     = "/"
}

variable "role_name" {
  description = "The IAM role that allows Amazon SNS to write logs for SMS deliveries in CloudWatch Logs."
  default     = "SNSSuccessFeedback"
}

variable "subscriptions" {
  description = "List of telephone numbers to subscribe to SNS."
  type        = list(string)
}