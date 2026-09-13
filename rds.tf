resource "aws_db_subnet_group" "oficina_db_subnet" {
  name       = "oficina-db-subnet"
  # MUDOU AQUI: Agora ele pega os IDs que o data.tf encontrou na AWS
  subnet_ids = data.aws_subnets.private_subnets.ids
}

resource "aws_security_group" "rds_sg" {
  name        = "oficina-rds-sg"
  description = "Permite acesso interno do EKS ao PostgreSQL"
  # MUDOU AQUI: Agora ele pega o ID da VPC encontrada pelo data.tf
  vpc_id      = data.aws_vpc.oficina_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # MUDOU AQUI: Pega o bloco de IP (CIDR) da VPC encontrada
    cidr_blocks = [data.aws_vpc.oficina_vpc.cidr_block] 
  }
}

resource "aws_db_instance" "oficina_db" {
  identifier             = "oficina-db-prod"
  engine                 = "postgres"
  engine_version         = "14"
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