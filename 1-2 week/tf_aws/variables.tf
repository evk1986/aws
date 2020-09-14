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
  type = "map"
  default = {
    "default_cidr" = "10.20.1.0/24"
  }

}