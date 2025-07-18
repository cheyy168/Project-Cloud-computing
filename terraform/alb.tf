# Create Application Load Balancer
resource "aws_lb" "web" {
  name               = "${var.project_name}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-alb"
  })
}

# Create ALB Target Group
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"  # Now checking the root which serves index.html
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"  
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-tg"
  })
}

# Create ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Attach Auto Scaling Group to Target Group
resource "aws_autoscaling_attachment" "web" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}


resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = "70"  # Scale out if CPU > 70%
  dimensions = { AutoScalingGroupName = aws_autoscaling_group.web.name }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-scale-out"
  scaling_adjustment     = 1  # Add 1 instance
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project_name}-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = "30"  # Scale in if CPU < 30%
  dimensions = { AutoScalingGroupName = aws_autoscaling_group.web.name }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-scale-in"
  scaling_adjustment     = -1  # Remove 1 instance
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.web.name
}

terraform init