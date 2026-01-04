variable "aws_region" {
  description = "Região da AWS (ex: us-east-1)"
  default     = "us-east-2"
}

variable "db_password" {
  description = "Senha do Banco de Dados RDS"
  type        = string
  sensitive   = true # Isso esconde a senha nos logs
}

variable "aws_access_key" {
  description = "Sua Access Key da AWS (para o S3)"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Sua Secret Key da AWS (para o S3)"
  type        = string
  sensitive   = true
}

variable "stripe_key" {
  description = "Chave Secreta da API Stripe (sk_test_...)"
  type        = string
  sensitive   = true
}