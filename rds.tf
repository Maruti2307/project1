resource "aws_db_subnet_group" "rds_subnet" {
  name       = "${var.project}-rds-subnet"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.project}-rds-subnet" }
}

resource "aws_db_instance" "rds" {
  identifier              = "${var.project}-rds"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_user
  password                = var.db_pass
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_encrypted       = true
  deletion_protection     = false
  tags = { Name = "${var.project}-rds" }
}
