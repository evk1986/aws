resource "aws_subnet" "rds" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.cloud.id
  cidr_block = "10.20.${length(data.aws_availability_zones.available.names) + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "rds-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_db_subnet_group" "dbsubnet" {
  name = "main"
  description = "Terraform example RDS subnet group"
  subnet_ids = [for s in aws_subnet.rds : s.id]
}

resource "aws_security_group" "rds" {
  name = "terraform_rds_security_group"
  description = "Terraform RDS POSTGRES server"
  vpc_id = aws_vpc.cloud.id
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [
      aws_security_group.security.id,
      aws_security_group.private_security.id,
    ]
  }
  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_instance" "dbinst1" {
  identifier = "rdstable"
  instance_class = "db.t2.micro"
  allocated_storage = 10
  engine = "postgres"
  name = "EduLohikaTrainingAwsRds"
  password = "rootuser"
  username = "rootuser"
  skip_final_snapshot = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.dbsubnet.id
  vpc_security_group_ids = [
    aws_security_group.rds.id]
  tags = {
    Name = "rds-database-instance"
  }
}