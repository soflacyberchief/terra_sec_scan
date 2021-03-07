resource "aws_db_option_group" "db_option_group" {
  engine_name              = "mysql"
  name                     = "og-${local.prefix.value}"
  major_engine_version     = "8.0"
  option_group_description = "Option Group for MySQL"

  tags = {
    Name = "${local.prefix.value}-og"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "pg-${local.prefix.value}"
  family      = "mysql8.0"
  description = "Terraform PG"

  parameter {
    name         = "character_set_client"
    value        = "utf8"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8"
    apply_method = "immediate"
  }

  tags = {
    Name = "${local.prefix.value}-pg"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${local.prefix.value}-db-subnet-group"
  subnet_ids  = [aws_subnet.private_subnet_2.id]
  description = "subnet group for RDS"

  tags = {
    Name = "${local.prefix.value}-pg"
  }
}

resource "aws_db_instance" "db_instance" {
  name                    = "${local.prefix.value}-db"
  engine                  = "mysql"
  option_group_name       = aws_db_option_group.db_option_group.name
  parameter_group_name    = aws_db_parameter_group.db_parameter_group.name
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  identifier              = "rds-${local.prefix.value}"
  engine_version          = "8.0" # Latest major version 
  instance_class          = "db.t3.micro"
  allocated_storage       = "20"
  username                = "admin"
  password                = var.password
  apply_immediately       = true
  multi_az                = false
  backup_retention_period = 0
  storage_encrypted       = false
  skip_final_snapshot     = true
  monitoring_interval     = 0
  publicly_accessible     = true

  tags = {
    Name = "${local.prefix.value}-db-instance"
  }
}

resource "aws_db_snapshot" "db_snapshot" {
  db_instance_identifier = aws_db_instance.db_instance.id
  db_snapshot_identifier = "${local.prefix.value}-db-snapshot"

  tags = {
    Name = "${local.prefix.value}-db-snapshot"
  }

}
