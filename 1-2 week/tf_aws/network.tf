resource "aws_vpc" "cloud" {
  cidr_block = var.vpc_cidr
  enable_classiclink = false
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.cloud.id
  cidr_block = lookup(var.subnets_cidr, "public")
  availability_zone = element(data.aws_availability_zones.available.names, 1 )
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnets"
  }
}

resource "aws_internet_gateway" "iGateway" {
  vpc_id = aws_vpc.cloud.id
  tags = {
    Name = "main-gateway"
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

resource "aws_route_table_association" "public_route" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtblPublic.id
}

resource "aws_security_group" "security" {
  vpc_id = aws_vpc.cloud.id
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      var.subnets_cidr.bastion,
      var.subnets_cidr.private]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [
      var.subnets_cidr.bastion,
      var.subnets_cidr.private
    ]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = [
      var.subnets_cidr.bastion,
      var.subnets_cidr.private
    ]
  }
  ingress {
    from_port = 5432
    protocol = "tcp"
    to_port = 5432
    cidr_blocks = [
      var.subnets_cidr.bastion,
      var.subnets_cidr.private
    ]
  }
  ingress {
    from_port = 53
    protocol = "udp"
    to_port = 53
    cidr_blocks = [
      var.subnets_cidr.bastion,
      var.subnets_cidr.private
    ]
  }
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "elb-bastion-allowed"
  }
}