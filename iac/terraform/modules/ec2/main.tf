resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.alb_sg_id] # Allow http traffic from only ALB sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_instance" "servers" {
  count                        = var.instance_count
  ami                          = var.ami
  instance_type                = var.instance_type
  subnet_id                    = var.subnet_ids[count.index % length(var.subnet_ids)]
  key_name                     = var.key_name   # 👈 REQUIRED FOR SSH
  associate_public_ip_address  = true
  vpc_security_group_ids       = [aws_security_group.sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd

    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

    cat <<HTML > /var/www/html/index.html
    <html>
      <head>
        <title>Ivan's Dev Ground</title>
        <style>
          body { font-family: Arial; background: #f8fafc; text-align: center; padding-top: 60px; }
          h1 { color: #4f46e5; }
        </style>
      </head>
      <body>
        <h1>Apache is running 🚀</h1>
        <p><strong>Instance:</strong> $INSTANCE_ID</p>
        <p><strong>AZ:</strong> $AZ</p>
      </body>
    </html>
    HTML
  EOF

  tags = {
    Name = "${var.name}-${count.index + 1}"
  }
}
