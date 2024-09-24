# Create ELB target group for EC2 instance
resource "aws_lb_target_group" "lb_tg" {
  name     = "eswap-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/api/greeting"
    port     = 3000
  }

  tags = {
    Name        = "eswap-lb-tg"
    Environment = "dev"
  }
}


# Register EC2 instance to target group and route traffic to app-serving port 
resource "aws_lb_target_group_attachment" "lb_tg_attachment" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.app_instance.id
  port             = 3000
}


# Create an ELB 
resource "aws_lb" "elb" {
  name               = "eswap-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  tags = {
    Name        = "eswap-elb"
    Environment = "dev"
  }
}


# Create a load balancer listener resource to forward traffic to EC2 target group 
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }

  tags = { 
    Name        = "eswap-elb-listener"
    Environment = "dev"
  }
}
