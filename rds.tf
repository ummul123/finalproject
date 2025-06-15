resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = ["subnet-0bd554e443dec9cb5", "subnet-0864702bc266c12d4"]
  }

resource "aws_db_instance" "postgres" {
  identifier             = "my-postgres-db"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "15.11"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "devops-123"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = false
  backup_retention_period = 0

  tags = {
    Name = "MyPostgresDB"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "mysql-db"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  username               = "ummul_mysql"
  password               = "devops-123"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = false
  backup_retention_period = 0
  db_name                = "assignmentdb"

  tags = {
    Name = "MySQLDB"
  }
}
