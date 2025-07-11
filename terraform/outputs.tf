output "alb_dns_name" {
  value       = aws_lb.web.dns_name
  description = "The DNS name of the Application Load Balancer"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.static_assets.bucket
  description = "The name of the S3 bucket for static assets"
}

output "website_url" {
  value       = "http://${aws_lb.web.dns_name}"
  description = "URL to access the website"
}

output "s3_website_url" {
  value       = "http://${aws_s3_bucket.static_assets.bucket}.s3-website-${var.region}.amazonaws.com"
  description = "S3 static website URL"
}