# data.tf no Repo 3 (Banco de Dados)

# Procura a VPC criada pelo Repo 2
data "aws_vpc" "oficina_vpc" {
  filter {
    name   = "tag:Name"
    values = ["oficina-vpc"] # Ajuste para a Tag exata que você usou no network.tf
  }
}

# Procura as Subnets Privadas dentro dessa VPC
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.oficina_vpc.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Private"] # Ajuste para a Tag exata das suas subnets privadas
  }
}