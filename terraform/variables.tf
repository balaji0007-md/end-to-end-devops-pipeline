
variable "aws_region" {
  description = "AWS region for our DevOps project"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the DevOps project"
  type        = string
  default     = "end-to-end-devops-pipeline"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "EC2 root EBS volume size in GiB"
  type        = number
  default     = 8
}

variable "allowed_ssh_cidr" {
  description = "Trusted public IPv4 address for SSH access"
  type        = string
  default     = null
}
variable "allowed_flask_cidr" {
  description = "Public IPv4 CIDR allowed to access Flask"
  type        = string
}