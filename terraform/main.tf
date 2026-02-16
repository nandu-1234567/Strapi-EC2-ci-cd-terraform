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
  key_name   = "strapi-ec2-key"
  public_key = tls_private_key.strapi_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.strapi_key.private_key_pem
  filename        = "strapi-key.pem"
  file_permission = "0400"
}

# Security group
resource "aws_security_group" "strapi_sg" {
  name = "strapi-ec2-sg"

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
--name strapi \
${var.docker_image}
EOF


  tags = {
    Name = "Strapi-EC2"
  }
}

