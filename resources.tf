data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["amazon"]


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-0a9a3e21dd5eb0dd8"

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.medium"
  key_name = "winkey"
  user_data = file("install_codedeploy.sh")
  vpc_security_group_ids =  [aws_security_group.sg.id]

  tags = {
    Name = "DevOps"
  }
  count=2
}

resource "aws_lb" "front_end" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = ["subnet-0e9227a33562c04cc","subnet-084e7b7ca96ee2612", "subnet-05cab79385a6dcc99"]

  enable_deletion_protection = true

  tags = {
    Environment = "demo"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0a9a3e21dd5eb0dd8"
}

resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.front_end.arn
  count = 2
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}