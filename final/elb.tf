resource "aws_security_group" "elb_http" {
  name = "elb_http"
  description = "Allow HTTP traffic to instances"
  vpc_id = aws_vpc.cloud.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "http-elb-security "
  }
}

resource "aws_elb" "elb" {
  name = "cluster-http-elb"
  subnets = [
    aws_subnet.public_subnet.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/health"
    interval = 30
  }

  cross_zone_load_balancing = true
  security_groups = [
    aws_security_group.elb_http.id]
  tags = {
    Name = "http-elb"
  }
}

output "ELB" {
  value = aws_elb.elb.dns_name
}