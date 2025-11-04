resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project}-web"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(file("scripts/user_data.sh"))

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "${var.project}-web"
    propagate_at_launch = true
  }
}
