resource "aws_instance" "bastion" {
  ami = var.ami
  instance_type = "t2.nano"
  key_name = "custom"
  subnet_id = aws_subnet.bastion_subnet.id
  vpc_security_group_ids = [
    aws_security_group.bastion_security.id]
  associate_public_ip_address = true
  tags = {
    Name = "cluster-bastion"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group" "bastion_security" {
  vpc_id = aws_vpc.cloud.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      var.subnets_cidr.public,
      var.subnets_cidr.private
    ]
  }

  tags = {
    Name = "cluster-bastion"
  }

}

output "bastion_dns_name" {
  value = aws_instance.bastion.public_dns
}
