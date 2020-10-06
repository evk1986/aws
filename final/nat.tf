data "aws_ami" "nat" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "nat_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "nat_role" {
  name_prefix = "narrole"
  role = aws_iam_role.nat_role.name
}

resource "aws_instance" "nat_instance" {
  ami = data.aws_ami.nat.id
  instance_type = "t2.nano"
  key_name = "custom"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [
    aws_security_group.security.id]
  associate_public_ip_address = true
  source_dest_check = false
  iam_instance_profile = aws_iam_instance_profile.nat_role.name
  tags = {
    Name = "cluster-nat-instance"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_default_route_table" "def-route-table" {
  default_route_table_id = aws_vpc.cloud.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance.id
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  route_table_id = aws_default_route_table.def-route-table.id
  subnet_id = aws_subnet.private_subnet.id
}


output "nat_ami_name" {
  value = data.aws_ami.nat.name
}


//resource "aws_vpc_endpoint" "s3" {
//  vpc_id          = aws_vpc.cloud.id
//  service_name    = "com.amazonaws.${var.region}.s3"
//  auto_accept     = true
//  route_table_ids = [aws_default_route_table.def-route-table.id]
//}