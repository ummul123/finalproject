resource "aws_launch_template" "web_app" {
  name_prefix   = "react-app-lt-"
  image_id      = "ami-09e6f87a47903347c" # Amazon Linux 2 AMI 
  instance_type = "t3.micro" 
  key_name      = var.key_name

  user_data = base64encode(file("al2_userdata.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Add tags to instances launched by this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "web-app-asg"  # Explicit name
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = ["subnet-0bdc4fd39f9ebfef1", "subnet-03c889316d8dfd2f9"]
  
  # Health check settings
  health_check_type         = "ELB"
  health_check_grace_period = 300  # 5 minutes
  
  launch_template {
    id      = aws_launch_template.web_app.id
    version = "$Latest"
  }
  
  target_group_arns = [aws_lb_target_group.web_app.arn]

  # Add tags to ASG and propagated to instances
  tag {
    key                 = "Name"
    value               = "web-app-instance"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }
}

# BI Instance (Metabase/Redash)
resource "aws_instance" "bi_instance" {
  ami                    = "ami-09e6f87a47903347c"
  instance_type          = "t3.medium"  # Upgraded for BI tool
  subnet_id              = "subnet-0bd554e443dec9cb5"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bi_sg.id]
  
  # Add instance metadata options for security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # IMDSv2 enforced
  }

  user_data = base64encode(file("bi_userdata.sh"))

  tags = {
    Name        = "BI-Tool-Instance"
    Application = "Metabase"
  }
}