variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "name" {
  description = "Name prefix for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  description = "Id/s of the ALB SG"
  type = string
}