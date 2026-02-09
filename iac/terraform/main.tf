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

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_azs = slice(data.aws_availability_zones.available.names, 0, 3)
  private_azs = slice(data.aws_availability_zones.available.names, 0, 2)

}

module "vpc" {
  source          = "./modules/vpc"
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = local.public_azs
}
 
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

resource "aws_security_group" "alb_sg" {
  name        = "${var.vpc_name}-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-alb-sg"
  }
}

# EC2 instances
module "public_ec2" {
  source         = "./modules/ec2"
  name           = "startup-public"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  ami            = var.ec2_ami        # declared in root variables.tf
  instance_type  = var.ec2_type       # declared in root variables.tf
  key_name       = var.ec2_key_name 
  alb_sg_id      = aws_security_group.alb_sg.id #http access restricted to alb sg
  ec2_sg_ids     = [aws_security_group.public_ec2_sg.id]
}

# Application load balancer - main
resource "aws_lb" "app" {
  name               = "${var.vpc_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnet_ids   #Use all available subnets

  tags = {
    Name = "${var.vpc_name}-alb"
  }
}

# Target group - logically group resource e.g ec2 that receive traffice fro the ALB via ALB listener
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.vpc_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.vpc_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id  = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Load balancer listeners - listen to traffic from ALB distribute to target group members
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}