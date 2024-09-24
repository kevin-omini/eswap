# Create key-pair to authenticate into EC2 instance
resource "aws_key_pair" "app_key" {
  key_name   = "eswap-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLtjrmlsTb39toOvr5/jup+YG7L7JhTmoGvaccYdo558aAz9bNC/4bIz25AwsI8ppDh1hCVU9bmF/4JBHZ9gt9SPRrQVwcBQzQFBr+j1c0f2wHED1VkdM1eXVRzyJXSg8eETlQ5FKDlL6w00O74to/kU1iFSAif1foBx+NTJMXOAU4I/F7MI2xN750yCeqwsbiKrHDlJ14aGuDqJHlLybhuq8Y4f3LaV1a5nhoZDQRipubCWmnrCQ+G84f+gZBTKFq1iGUJ/ri63UZO+k17Jcbc3LzuzIsahlQWYz/TUos3S8elY2Kf0eK6CoGVZWSJ7SJlADfdMcH52sVbGZgC0Eh2IqewYcs76xrt3LdVFXK0Vi4jMTSQy2bCTrnbU5yU+UD20KQVqQ0k6Xu++78Nb9jj/0ae3EatEMlV+/PAVo7g5htUMm3CyzfjnNnprJ1Gawz+wGW3AJh4Khi9REvUSdt0QV8JeBDBCOWxhH/PoG8zLwnobH3yY10vYKMk3N0LpU= kevin@LAPTOP"
}


# Create security group to allow http inbound traffic on port 22,80 and 3000 and all outbound traffic
resource "aws_security_group" "allow_http" {
  name        = "allow-http"
  description = "Allow http inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "allow-http"
    Environment = "dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_3000" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Create EC2 instance
resource "aws_instance" "app_instance" {
  ami                         = "ami-07d20571c32ba6cdc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_http.id]
  key_name                    = aws_key_pair.app_key.id

  tags = {
    Name        = "eswap-app-server"
    Environment = "dev"
  }

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}
