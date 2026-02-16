provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "strapi" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  security_groups = ["strapi-sg"]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 1337:1337 ${var.docker_image}
              EOF

  tags = {
    Name = "Strapi-EC2"
  }
}

resource "aws_security_group" "strapi_sg" {
  name = "strapi-sg"

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
