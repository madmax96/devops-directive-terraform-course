resource "aws_db_instance" "db_instance" {
  allocated_storage   = 10
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t3.micro"
  name                = var.db_name
  username            = var.db_user
  password            = var.db_pass
  skip_final_snapshot = true

  tags = {
    Name = "my awesome DB"
  }
}
