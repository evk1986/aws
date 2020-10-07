locals {
  private-instance-userdata = <<EOF
#!/bin/bash -xe
export PATH=$PATH:/usr/local/bin
cat /etc/yum.conf > /var/log/user-script.conf
echo "Infra preparing started" >> /var/log/user-script.log
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
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

export PGPASSWORD=${aws_db_instance.dbinst1.password}
export PGHOSTADDR=${aws_db_instance.dbinst1.address}
export PGUSER=${aws_db_instance.dbinst1.username}
export PGPASSWORD=${aws_db_instance.dbinst1.password}

echo "Infra java8 installation fibished" >> /var/log/user-script.log
/usr/bin/aws s3 cp s3://${aws_s3_bucket.my_bucket.id}/${aws_s3_bucket_object.private_artifact.id} /opt/${aws_s3_bucket_object.private_artifact.id}.jar

java -jar /opt/${aws_s3_bucket_object.private_artifact.id}.jar > /opt/log.log
  EOF
}

resource "aws_launch_configuration" "private_ec2_lconfig" {
  image_id = var.ami
  instance_type = var.ec2_type
  key_name = "custom"
  enable_monitoring = false
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  security_groups = [
    aws_security_group.private_security.id]
  user_data_base64 = base64encode(local.private-instance-userdata)

  lifecycle {
    create_before_destroy = false
  }

}

resource "aws_autoscaling_group" "private_ascaling" {
  launch_configuration = aws_launch_configuration.private_ec2_lconfig.name
  vpc_zone_identifier = [
    aws_subnet.private_subnet.id
  ]

  desired_capacity = 1
  max_size = 1
  min_size = 1

  lifecycle {
    create_before_destroy = false
  }

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "private-instance"
  }
}

data "aws_instances" "private_ec2" {
  depends_on = [aws_autoscaling_group.private_ascaling]
  instance_tags = {
    Name = "private-instance"
  }
}

output "private-ip" {
  value = data.aws_instances.private_ec2.private_ips
}