output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "ec2_public_ips" {
  value = module.public_ec2.public_ips
}

output "ec2_instance_ids" {
  value = module.public_ec2.instance_ids
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}