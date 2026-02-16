variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0b6c6ebed2801a5cb"  # Ubuntu 22.04 LTS in us-east-1
}

variable "docker_image" {
  description = "Docker image to run Strapi"
  type        = string
}
