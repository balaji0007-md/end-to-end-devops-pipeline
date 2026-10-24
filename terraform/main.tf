
# Find the default VPC in the selected AWS region
data "aws_vpc" "default" {
  default = true
}

# Find a subnet in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Find a recent Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Security group for the Flask application
resource "aws_security_group" "flask" {
  name_prefix = "${var.project_name}-"
  description = "Security group for Flask DevOps lab"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# Allow SSH only from your trusted IP
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count = var.allowed_ssh_cidr == null ? 0 : 1

  security_group_id = aws_security_group.flask.id
  description       = "SSH from trusted public IP"

  cidr_ipv4   = var.allowed_ssh_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# Allow access to the Flask application
resource "aws_vpc_security_group_ingress_rule" "flask" {
  security_group_id = aws_security_group.flask.id
  description       = "Flask application"

  cidr_ipv4   = var.allowed_flask_cidr
  from_port   = 5000
  to_port     = 5000
  ip_protocol = "tcp"
}

# Allow outbound traffic
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.flask.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Launch an Ubuntu EC2 instance
resource "aws_instance" "flask" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.flask.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  user_data                   = file("${path.module}/user-data.sh")
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}

# Allow the EC2 service to assume this IAM role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for the EC2 instance
resource "aws_iam_role" "ec2_ssm" {
  name_prefix        = "devops-flask-ssm-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Project = var.project_name
  }
}

# Attach AWS-managed SSM permissions
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an instance profile for EC2
resource "aws_iam_instance_profile" "ec2_ssm" {
  name_prefix = "devops-flask-ssm-"
  role        = aws_iam_role.ec2_ssm.name
}
