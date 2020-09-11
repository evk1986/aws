provider "aws" {
  profile = var.PROFILE
  region = var.AWS_REGION
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_key_pair" "root" {
  public_key = "root_key_pair"
}

resource "aws_vpc" "cloud" {
  cidr_block = "10.0.0.0/16"
  enable_classiclink = false

}

resource "aws_subnet" "main-public-subnet" {
  vpc_id = "${aws_vpc.cloud.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "main-public-subnet"
  }
}


resource "aws_security_group" "security" {
  vpc_id = aws_vpc.cloud.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "ssh allowed"
  }
}

resource "aws_launch_configuration" "dummy" {
  image_id = var.AMI
  instance_type = var.EC2_TYPE
  key_name = "syntetich"
  enable_monitoring = false
  security_groups = [
    "${aws_security_group.security.id}"]
  user_data = <<EOF
  #!/bin/bash -xe
  sudo yum install -y java-1.8.0-openjdk.x86_64
  sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
  sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac
  sudo yum remove java-1.7
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ascaling" {
  launch_configuration = aws_launch_configuration.dummy.name
  availability_zones = [
    "${data.aws_availability_zones.available.names[0]}"]
  desired_capacity = 2
  force_delete = true
  max_size = 2
  min_size = 1

  lifecycle {
    create_before_destroy = true
  }
}


