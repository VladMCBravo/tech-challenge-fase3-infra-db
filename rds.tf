resource "aws_db_subnet_group" "oficina_db_subnet" {
  name       = "oficina-db-subnet-v3"
  subnet_ids = data.aws_subnets.private_subnets.ids
}

resource "aws_security_group" "rds_sg" {
  name        = "oficina-rds-sg-v3"
  description = "Permite acesso interno ao PostgreSQL (EKS e Lambda de auth)"
  vpc_id      = data.aws_vpc.oficina_vpc.id

  # Entrada: PostgreSQL (5432) de dentro da VPC
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.oficina_vpc.cidr_block]
  }

  # Entrada: permite recursos que usam ESTE MESMO SG (a Lambda de auth) na 5432
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    self      = true
  }

  # ⚠️ Saída OBRIGATÓRIA:
  # A Lambda de autenticação usa ESTE SG e precisa INICIAR a conexão com o RDS.
  # Sem este bloco, o Terraform remove a saída padrão e a Lambda dá "connect ETIMEDOUT".
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  publicly_accessible    = false # Segurança: sem acesso direto pela internet

  tags = {
    Environment = "tech-challenge"
  }
}