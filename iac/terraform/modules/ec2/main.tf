# We don't need instances for auto scaling. Auto Scaling Group auto creates & destroy instance
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.sg.id,
    var.alb_sg_id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd

    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

    cat <<HTML > /var/www/html/index.html
    <h1>Apache running 🚀</h1>
    <p>Instance: $INSTANCE_ID</p>
    <p>AZ: $AZ</p>
    HTML
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
}
