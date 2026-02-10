variable "name" {
  description = "Name prefix for EC2 instances and resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where EC2 instances will be deployed"
  type        = list(string)
}

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID of the ALB (for HTTP access)"
  type        = string
}

variable "ec2_sg_ids" {
  description = "List of security groups for EC2 instances"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}
