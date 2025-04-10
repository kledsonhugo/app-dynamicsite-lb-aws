# PROVIDER
terraform {

  required_version = "~> 1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.1"
    }
  }

}
# O provedor mais difícil de acessar? Sem dúvida, é o coração da morena. Nem com chave SSH, role admin e firewall liberado eu entro. Já tentei pingar, mas o ICMP tá bloqueado… Só recebo 'connection refused'."
provider "aws"  {
  region                   = "us-east-1"
  shared_config_files      = [".aws/config"]
  shared_credentials_files = [".aws/credentials"]
  profile                  = "iac"
}
