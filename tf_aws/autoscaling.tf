provider "aws" {
  profile = var.profile
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "cloud" {
  cidr_block = var.vpc_cidr
  enable_classiclink = false
}

resource "aws_internet_gateway" "iGateway" {
  vpc_id = "${aws_vpc.cloud.id}"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main-public-subnet" {
  vpc_id = "${aws_vpc.cloud.id}"
  cidr_block = "${var.subnets_cidr}"
  availability_zone_id = "${element(data.aws_availability_zones.available.zone_ids, 0)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.cloud.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.iGateway.id}"
  }

  tags = {
    Name = "publicRouteTable"
  }
}

resource "aws_route_table_association" "a" {
  count = "${length(var.subnets_cidr)}"
  subnet_id = "${aws_subnet.main-public-subnet.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_security_group" "security" {
  vpc_id = aws_vpc.cloud.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      var.subnets_cidr]
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
  image_id = var.ami
  instance_type = var.ec2_type
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


