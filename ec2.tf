data "aws_ami" "ubuntu_canonical" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "nginx" {
  template = file("./modules/customer/nginx.sh")

  vars = {
    password = var.password
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.nginx.rendered
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  size              = 10
  type              = "gp2"
  tags = {
    Name = "${local.prefix.value}-ebs-volume"
  }
}

resource "aws_ebs_snapshot" "ebs_snapshot" {
  volume_id   = aws_ebs_volume.ebs_volume.id
  description = "${local.prefix.value}-ebs-snapshot"
  tags = {
    Name = "${local.prefix.value}-ebs-snapshot"
  }
}

resource "aws_key_pair" "keypair" {
  key_name   = "${local.prefix.value}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrBlaHabVohBK41 email@mydomain.com"
}

resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu_canonical.id
  instance_type = "t3.nano"

  vpc_security_group_ids = [
    aws_security_group.default_sg.id
  ]

  subnet_id            = aws_subnet.private_subnet_1.id
  user_data            = data.template_cloudinit_config.config.rendered
  key_name             = aws_key_pair.keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  tags = {
    Name = "${local.prefix.value}-ec2-instance"
  }
}

resource "aws_volume_attachment" "volume_attach" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.ebs_volume.id
  instance_id  = aws_instance.ec2_instance.id
  skip_destroy = true

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.prefix.value}-instance-profile"
  role = aws_iam_role.instance_role.name
}

#Load Balancer 
resource "aws_lb_target_group" "alb_target" {
  name     = "alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix.value}-alb-target"
  }

}

resource "aws_lb_target_group_attachment" "alb_attachment" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = aws_instance.ec2_instance.id
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "${local.prefix.value}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default_sg.id]
  subnets            = [aws_subnet.public_subnet_2.id]
  ip_address_type    = "ipv4"

  tags = {
    Name = "${local.prefix.value}-alb"
  }

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }
}

resource "aws_lb_listener_certificate" "lb_cert" {
  listener_arn    = aws_lb_listener.listener.arn
  certificate_arn = aws_acm_certificate.cert.arn
}
