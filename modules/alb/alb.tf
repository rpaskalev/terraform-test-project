# app1 launch-template
#########################################

resource "aws_launch_template" "foo" {
  name = "app1-launch-template"
  image_id = data.aws_ami.amazon_linux_2023.image_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.instance_type
  key_name = aws_key_pair.rsa-key-deployer.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
    }
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups   = var.vpc_security_group
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
    Name        =   "${var.environment}-app1-launch-template"
    Environment =   var.environment
    }
  }
   user_data = filebase64(var.user_data_app1)
}
# app2 launch-template
resource "aws_launch_template" "foo2" {
  name = "app2-launch-template"
  image_id = data.aws_ami.amazon_linux_2023.image_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.instance_type
  key_name = aws_key_pair.rsa-key-deployer.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
    }
  }
  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups   = var.vpc_security_group

  }
  tag_specifications {
    resource_type = "instance"

    tags = {
    Name        =   "${var.environment}-app2-launch-template"
    Environment =   var.environment
    }
  }
  user_data = filebase64(var.user_data_app2)
}

# ASG-app1
#########################################
resource "aws_autoscaling_group" "app1_asg" {
  name                 = "project-app1-asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  force_delete              = true
  health_check_grace_period = 0
  health_check_type         = "ELB"
  vpc_zone_identifier  = var.asg_vpc_zone_identifier
  target_group_arns = [aws_lb_target_group.app1.arn]

  launch_template {
    id = aws_launch_template.foo.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-app1-instance"
    propagate_at_launch = true
  }
}

# ASG-app2
#########################################
resource "aws_autoscaling_group" "app2_asg" {
  name = "project-app2-asg"
  
  min_size                    = 1
  max_size                    = 3
  desired_capacity            = 1
    force_delete              = true
  health_check_grace_period   = 0
  health_check_type           = "ELB"
  vpc_zone_identifier  = var.asg_vpc_zone_identifier
  target_group_arns = [aws_lb_target_group.app2.arn]

  launch_template {
    id = aws_launch_template.foo2.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-app2-instance"
    propagate_at_launch = true
  }
}


# ALB app1-tg
resource "aws_lb_target_group" "app1" {
  name     = "app1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

    health_check {
      path = "/"
      port = 80
    }
    tags = {
      Name        =   "${var.environment}-app1-tg"
      Environment =   var.environment
    }
}

# ALB Target Group attachment
resource "aws_autoscaling_attachment" "app1" {
  autoscaling_group_name = aws_autoscaling_group.app1_asg.id
  lb_target_group_arn    = aws_lb_target_group.app1.arn
}


# Application Load Balancer
resource "aws_lb" "project_alb" {
  name               = "project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.vpc_security_group  
  subnets            = var.alb-subnets

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

    tags = {
    Name        =   "${var.environment}-project-lb"
    Environment =   var.environment
  }
}

#Listener for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.project_alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.app1.arn
  # }
    default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "default"
      status_code  = "200"
    }
  }
}

# Listener Rule for app1
resource "aws_lb_listener_rule" "app1-rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type = "forward"
    # forward {
    #   target_group {
    #     arn    = aws_lb_target_group.app1.arn
    #     weight = 50
    #   }

    #   target_group {
    #     arn    = aws_lb_target_group.app2.arn
    #     weight = 50
    #   }
    # }
    target_group_arn = aws_lb_target_group.app1.arn
  }
  # action {
  #   type               = "forward"
  #   target_group_arn   = aws_lb_target_group.app1.arn
  # }

  condition {
    path_pattern {
      values = ["/app1/*"]
    }
  }
}
##########################################################
# ALB app2-tg
resource "aws_lb_target_group" "app2" {
  name     = "app2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

    health_check {
      path = "/"
      port = 80
    }
    tags = {
      Name        =   "${var.environment}-app2-tg"
      Environment =   var.environment
    }
}

# ALB Target Group attachment
resource "aws_autoscaling_attachment" "app2_asg" {
  autoscaling_group_name = aws_autoscaling_group.app2_asg.id 
  lb_target_group_arn    = aws_lb_target_group.app2.arn 
}

# resource "aws_lb_target_group_attachment" "test2" {
#   target_group_arn = aws_lb_target_group.app2.arn
#   target_id        = aws_instance.web_server1.id
#   port             = 80
# }

# Listener rule app2 
resource "aws_lb_listener_rule" "app2-rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.app2.arn
  }

  condition {
    path_pattern {
      values = ["/app2/*"]
    }
  }
}


## TF resource, NOT AWS -just creates key in backend
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## AWS creates the SSH Key with this. Must add "public_key_openssh" at the end 
resource "aws_key_pair" "rsa-key-deployer" {
  key_name   = "project-ssh-keypair"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

## Pushing the RSA Key to SSM PS. Must add "private_key_pem" at the end  
resource "aws_ssm_parameter" "rsa-private-ssh-key" {   
  name  = "project-ssh-keypair"                        
  type  = "SecureString"                              
  value = tls_private_key.rsa-4096.private_key_pem     
}
