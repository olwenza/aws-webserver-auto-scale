# We don't need instances for auto scaling. Auto Scaling Group auto creates & destroy instance
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = concat(var.ec2_sg_ids, [var.alb_sg_id])
  
  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -e

    # -----------------------------
    # System updates
    # -----------------------------
    yum update -y

    # -----------------------------
    # Install packages
    # -----------------------------
    yum install -y git nginx curl

    # -----------------------------
    # Install Node.js 18 (Vite compatible)
    # -----------------------------
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs

    node -v
    npm -v

    # -----------------------------
    # Clone React app
    # -----------------------------
    APP_DIR=/opt/landing-page

    rm -rf $APP_DIR
    git clone https://github.com/olwenza/landing-page.git $APP_DIR
    cd $APP_DIR

    # -----------------------------
    # Install deps & build
    # -----------------------------
    npm install
    npm run build

    # -----------------------------
    # Configure Nginx (SPA support)
    # -----------------------------
    cat <<'NGINXEOF' > /etc/nginx/conf.d/react.conf
    server {
        listen 80;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
    NGINXEOF

    # Remove default config
    rm -f /etc/nginx/conf.d/default.conf

    # -----------------------------
    # Deploy build files
    # -----------------------------
    rm -rf /usr/share/nginx/html/*
    cp -r dist/* /usr/share/nginx/html/
    chown -R nginx:nginx /usr/share/nginx/html

    # -----------------------------
    # Enable & start Nginx
    # -----------------------------
    systemctl enable nginx
    systemctl restart nginx
    USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-asg"
  desired_capacity    = 3
  min_size            = 3
  max_size            = 6

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [var.target_group_arn]  # <-- use the new variable

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}

