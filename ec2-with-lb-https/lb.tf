
# Retrieve default subnets
data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnet" "default_subnet" {
  id = data.aws_subnets.default.ids[0]  # Use the first subnet ID to get its VPC ID
}

resource "aws_lb_target_group" "lb-TG" {
  name = "LB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id = data.aws_subnet.default_subnet.vpc_id
}

resource "aws_lb_target_group_attachment" "wordpress-tg" {

  target_group_arn = aws_lb_target_group.lb-TG.arn
  target_id        =  aws_instance.steve1.id
}

# Create Load Balancer
resource "aws_lb" "app-LB" {
  name = "APP-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.LB-SG.id]
  subnets            = data.aws_subnets.default.ids  
 
}

# We want to foward traffic from HTTP/80 to our TG
resource "aws_lb_listener" "LB-Listener" {
  load_balancer_arn = aws_lb.app-LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-TG.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app-LB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-TG.arn
  }
}