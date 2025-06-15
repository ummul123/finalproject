#!/bin/bash

# Update system
sudo yum update -y

# Install Docker
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Pull and run Metabase (or Redash)
docker run -d -p 3001:3000 --name metabase metabase/metabase
