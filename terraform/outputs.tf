output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.mc_server.public_ip
}