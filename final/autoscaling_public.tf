locals {
  public-instance-userdata = <<EOF
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
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
echo "Infra java8 installation fibished" >> /var/log/user-script.log
/usr/bin/aws s3 cp s3://${aws_s3_bucket.my_bucket.id}/${aws_s3_bucket_object.public_artifact.id} /opt/${aws_s3_bucket_object.public_artifact.id}.jar

java -jar /opt/${aws_s3_bucket_object.public_artifact.id}.jar > /opt/log.log
  EOF
}

resource "aws_launch_configuration" "public_ec2_lconfig" {
  image_id = var.ami
  instance_type = var.ec2_type
  key_name = "custom"
  enable_monitoring = false
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  security_groups = [
    aws_security_group.security.id]
  user_data_base64 = base64encode(local.public-instance-userdata)

  lifecycle {
    create_before_destroy = false
  }

}

resource "aws_autoscaling_group" "public_ascaling" {
  launch_configuration = aws_launch_configuration.public_ec2_lconfig.name
  vpc_zone_identifier = [
    aws_subnet.public_subnet.id
  ]
  desired_capacity = 2
  max_size = 2
  min_size = 2

  health_check_type = "ELB"
  load_balancers = [
    aws_elb.elb.id]

  lifecycle {
    create_before_destroy = false
  }

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "public-instance"
  }
}


data "aws_instances" "public_ec2" {
  depends_on = [aws_autoscaling_group.public_ascaling]
  instance_tags = {
    Name = "public-instance"
  }
}

output "public-ip" {
  value = data.aws_instances.public_ec2.private_ips
}