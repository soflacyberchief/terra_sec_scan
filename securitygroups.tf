resource "aws_security_group" "default_sg" {
  depends_on = [aws_vpc.vpc]
  name        = "${local.prefix.value}-sg"
  description = "${local.prefix.value} Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  

  tags = {
    Name = "${local.prefix.value}-default-sg"
  }
}

resource "aws_security_group" "db_sg" {
    name = "${local.prefix.value}-db-sg"
    description = "${local.prefix.value} DB Security Group"
    vpc_id      = aws_vpc.vpc.id

    tags = {
    Name = "${local.prefix.value}-db-sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
}

