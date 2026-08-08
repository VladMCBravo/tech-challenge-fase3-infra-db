resource "aws_db_subnet_group" "oficina_db_subnet" {
  name       = "oficina-db-subnet"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "rds_sg" {
  name        = "oficina-rds-sg"
  description = "Permite acesso interno do EKS ao PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # Apenas quem está dentro da VPC acede
  }
}

resource "aws_db_instance" "oficina_db" {
  identifier             = "oficina-db-prod"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.oficina_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false # Segurança máxima: sem acesso direto pela internet

  tags = {
    Environment = "tech-challenge"
  }
}