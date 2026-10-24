output "instance_id" {
  description = "EC2 instance ID for the Flask application"
  value       = aws_instance.flask.id
}

output "public_ip" {
  description = "Public IP address of the Flask EC2 instance"
  value       = aws_instance.flask.public_ip
}

output "flask_url" {
  description = "Public health-check URL for the Flask application"
  value       = "http://${aws_instance.flask.public_ip}:5000/health"
}