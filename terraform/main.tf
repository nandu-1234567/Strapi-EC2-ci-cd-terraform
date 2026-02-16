provider "aws" {
  region = var.aws_region
}

# Generate SSH key
resource "tls_private_key" "strapi_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "strapi_key" {
  key_name   = "strapi-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.strapi_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.strapi_key.private_key_pem
  filename        = "strapi-key.pem"
  file_permission = "0400"
}

# Random suffix for uniqueness
resource "random_id" "key_suffix" {
  byte_length = 2
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security group
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-${random_id.sg_suffix.hex}"
  description = "Security group for Strapi EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Strapi-SG"
  }
}

# Random suffix for SG
resource "random_id" "sg_suffix" {
  byte_length = 2
}

# EC2 instance
resource "aws_instance" "strapi_ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.strapi_key.key_name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker

    docker run -d \
      -p 1337:1337 \
      -e NODE_ENV=production \
      -e APP_KEYS=key1,key2,key3,key4 \
      --name strapi-app \
      ${var.docker_image}
  EOF

  tags = {
    Name = "Strapi-EC2"
  }
}

