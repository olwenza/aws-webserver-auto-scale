variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)

  validation {
    condition     = length(var.public_subnets) >= 3
    error_message = "At least 3 public subnets are required."
  }
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
