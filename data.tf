# data.tf — Repo Banco de Dados
#
# NOTA: fixamos a VPC e as subnets por ID de propósito.
# Havia VÁRIAS VPCs com a mesma tag "Name = oficina-vpc" (sobras de applies/resets
# anteriores), o que deixava a busca por tag ambígua:
#   "multiple EC2 VPCs matched; use additional constraints..."
# Fixar por ID aponta exatamente para os recursos onde o RDS realmente está.

# VPC onde o RDS/EKS vivem
data "aws_vpc" "oficina_vpc" {
  id = "vpc-04819097f65faf999"
}

# Subnets privadas usadas pelo RDS (as mesmas do DB Subnet Group)
data "aws_subnets" "private_subnets" {
  filter {
    name   = "subnet-id"
    values = [
      "subnet-0b868a33706dd184a",
      "subnet-0e66981f57714d07c",
    ]
  }
}