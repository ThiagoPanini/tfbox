/* --------------------------------------------------------
ARQUIVO: versions.tf @ aws/dynamodb-table module

Configuração de versão do Terraform e do provider utilizado
para implantação de recursos de infraestrutura do módulo.
-------------------------------------------------------- */

terraform {
  required_version = ">= 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}
