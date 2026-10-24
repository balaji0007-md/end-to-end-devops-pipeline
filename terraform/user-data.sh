#!/bin/bash
set -euxo pipefail

# Update Ubuntu package lists
apt-get update -y

# Install Docker
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io

# Start Docker automatically
systemctl enable --now docker

# Start SSM Agent if available
if snap list amazon-ssm-agent >/dev/null 2>&1; then
  snap start amazon-ssm-agent
fi

# Pull our Flask Docker image
docker pull balajimd07/balaji-flask-service:latest

# Run our Flask application
docker run -d \
  --name balaji-flask-prod \
  --restart unless-stopped \
  -p 5000:5000 \
  balajimd07/balaji-flask-service:latest
