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
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.cloud.id
  cidr_block = var.subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
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
  count = length(var.subnets_cidr)
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
      "0.0.0.0/0"]
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

locals {
  instance-userdata = <<EOF
#!/bin/bash -xe
export PATH=$PATH:/usr/local/bin
echo "Infra preparing started" > /var/log/user-script.log
yum -y update
yum -y install epel-release
echo "Infra epel-release installed" >> /var/log/user-script.log
yum -y install python-pip
echo "Infra pip installed" >> /var/log/user-script.log
pip install --upgrade pip
yum -y install awscli
echo "Infra  awscli installed" >> /var/log/user-script.log
yum -y install postgresql
echo "Infra  postgres installed" >> /var/log/user-script.log
/usr/bin/aws s3 cp s3://${aws_s3_bucket.my_bucket.id}/${aws_s3_bucket_object.sql_init.id} /opt/${aws_s3_bucket_object.sql_init.id}.sql
/usr/bin/aws s3 cp s3://${aws_s3_bucket.my_bucket.id}/${aws_s3_bucket_object.dunamo_db_init_script.id} /opt/${aws_s3_bucket_object.dunamo_db_init_script.id}.sh
chmod 0777 /opt/${aws_s3_bucket_object.dunamo_db_init_script.id}.sh
export PGPASSWORD=${aws_db_instance.dbinst1.password}
echo  ${aws_db_instance.dbinst1.password}
echo ${aws_db_instance.dbinst1.username}
psql -h ${aws_db_instance.dbinst1.address} -U ${aws_db_instance.dbinst1.username} -d postgres -a -f /opt/${aws_s3_bucket_object.sql_init.id}.sql
psql -h ${aws_db_instance.dbinst1.address} -U ${aws_db_instance.dbinst1.username} -d postgres -a -c "select * from test_data" > /var/log/test-results.log
/opt/${aws_s3_bucket_object.dunamo_db_init_script.id}.sh
  EOF
}

resource "aws_launch_configuration" "dummy" {
  image_id = var.ami
  instance_type = var.ec2_type
  key_name = "custom"
  enable_monitoring = false
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  security_groups = [
    aws_security_group.security.id]
  user_data_base64 = base64encode(local.instance-userdata)
}

resource "aws_autoscaling_group" "ascaling" {
  count = length(aws_subnet.public_subnet)
  launch_configuration = aws_launch_configuration.dummy.name
  vpc_zone_identifier = [
    aws_subnet.public_subnet[count.index].id]
  desired_capacity = 1
  max_size = 1
  min_size = 1
}