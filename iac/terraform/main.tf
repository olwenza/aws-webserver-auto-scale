terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source          = "./modules/vpc"
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = data.aws_availability_zones.available.names
}

# Add this below the VPC module call
resource "aws_security_group" "public_ec2_sg" {
  name        = "${var.vpc_name}-public-ec2-sg"
  description = "Allow SSH access to public EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-public-ec2-sg"
  }
}

# EC2 instances
module "public_ec2" {
  source         = "./modules/ec2"
  name           = "startup-public"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.public_subnet_ids[0]
  ami            = var.ec2_ami        # declared in root variables.tf
  instance_type  = var.ec2_type       # declared in root variables.tf
  instance_count = 2
}
