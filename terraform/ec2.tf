# Data source to get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "web" {
  name_prefix   = "cyber-trends-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  # ✅ FIXED: Use security group **IDs** instead of names
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Cyber Security Trends 2025 kakak
              https://cyber-trends-static-assets-dev-007536ca.s3.us-west-2.amazonaws.com/index.html</h1>" > /var/www/html/index.html
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_security_group.web,
    aws_iam_instance_profile.ec2
  ]
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-web-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = [for subnet in aws_subnet.public : subnet.id]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-instance"
    propagate_at_launch = true
  }
}
