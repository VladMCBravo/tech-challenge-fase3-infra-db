# State remoto no S3.
# Sem isso, cada execução do pipeline "esquece" o que existe e tenta recriar
# o RDS/SG/subnet-group (erro "already exists"). Com o state no S3, o Terraform
# passa a ter memória entre execuções e o apply fica idempotente.
#
# ⚠️ O bucket precisa existir ANTES do primeiro "terraform init".
#    Crie uma vez (no terminal do lab):
#      aws s3 mb s3://tf-state-oficina-538889416411-use1 --region us-east-1
terraform {
  backend "s3" {
    bucket = "tf-state-oficina-538889416411-use1"
    key    = "infra-db/terraform.tfstate"
    region = "us-east-1"
  }
}