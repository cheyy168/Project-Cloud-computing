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
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd awscli
              systemctl start httpd
              systemctl enable httpd
              
              # Create web directory
              mkdir -p /var/www/html
              
              # Download index.html from S3
              aws s3 cp s3://${aws_s3_bucket.static_assets.bucket}/index.html /var/www/html/index.html
              
              # Set proper permissions
              chown -R apache:apache /var/www/html
              chmod -R 755 /var/www/html
              
              # Restart httpd to apply changes
              systemctl restart httpd
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
  target_group_arns   = [aws_lb_target_group.web.arn]

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