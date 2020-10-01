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