output "public_ips" {
  value = aws_instance.servers[*].public_ip
}

output "instance_ids" {
  value = aws_instance.servers[*].id
}