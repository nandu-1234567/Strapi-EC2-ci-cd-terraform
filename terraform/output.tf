output "public_ip" {
  description = "Public IP address of the Strapi EC2 instance"
  value       = aws_instance.strapi_ec2.public_ip
}

output "private_key_path" {
  description = "Path to the generated private key file"
  value       = local_file.private_key.filename
}
