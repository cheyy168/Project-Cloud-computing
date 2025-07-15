# security.tf - Enhanced and Clean

# Web Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-sg-"
  description = "Allow HTTP and SSH traffic to EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere (replace for production)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2" {
  name_prefix        = "${var.project_name}-ec2-role-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2-role"
  })
}

# IAM Policy Document for Assume Role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Custom S3 Read-Only Policy
data "aws_iam_policy_document" "s3_read" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.static_assets.arn,
      "${aws_s3_bucket.static_assets.arn}/*"
    ]
  }
}

# Attach Custom Inline Policy to EC2 Role
resource "aws_iam_role_policy" "s3_read_only" {
  name_prefix = "${var.project_name}-s3-read-"
  role        = aws_iam_role.ec2.id
  policy      = data.aws_iam_policy_document.s3_read.json
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${var.project_name}-ec2-profile-"
  role        = aws_iam_role.ec2.name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2-profile"
  })
}