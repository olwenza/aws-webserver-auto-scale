resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-sg" }
}

resource "aws_instance" "servers" {
  count                     = var.instance_count
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids    = [aws_security_group.sg.id]

  tags = {
    Name = "${var.name}-${count.index + 1}"
  }
}
