provider "aws" {
  profile = var.profile
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "cloud" {
  cidr_block = var.vpc_cidr
  enable_classiclink = false
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_internet_gateway" "iGateway" {
  vpc_id = aws_vpc.cloud.id
  tags = {
    Name = "main-gateway"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.cloud.id
  cidr_block = var.subnets_cidr.default_cidr
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnets"
  }
}

resource "aws_route_table" "rtblPublic" {
  vpc_id = aws_vpc.cloud.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iGateway.id
  }
  tags = {
    Name = "rtblPublic"
  }
}

resource "aws_route_table_association" "route" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.rtblPublic.id
}

resource "aws_security_group" "security" {
  vpc_id = aws_vpc.cloud.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      var.subnets_cidr.default_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "main-ssh-allowed"
  }
}

resource "aws_launch_configuration" "dummy" {
  image_id = var.ami
  instance_type = var.ec2_type
  key_name = "syntetich"
  enable_monitoring = false
  security_groups = [
    aws_security_group.security.id]
  user_data = <<EOF
  #!/bin/bash -xe
  sudo yum install -y java-1.8.0-openjdk.x86_64
  sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
  sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac
  sudo yum remove java-1.7
  EOF
}

resource "aws_autoscaling_group" "ascaling" {
  launch_configuration = aws_launch_configuration.dummy.name
  vpc_zone_identifier = [
    aws_subnet.public_subnet.id]
  desired_capacity = 1
  max_size = 1
  min_size = 1
}