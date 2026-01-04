provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# --- Pesquisar a imagem do Ubuntu mais recente automaticamente ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID da Canonical (Criadora do Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- 1. Rede e Segurança ---
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "foodapp_sg" {
  name        = "foodapp-security-group"
  description = "Permitir HTTP, SSH e App"
  vpc_id      = data.aws_vpc.default.id

  # --- REGRA NOVA: Permite o EC2 falar com o RDS ---
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    self      = true
  }

  # Porta do Front-end
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Porta do Back-end API
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (Para você entrar se precisar)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Saída liberada para internet (para baixar o Docker)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
# --- 2. O Banco de Dados (RDS) ---
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "fooddb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Free tier elegível
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.foodapp_sg.id]
}

 */

# --- 3. O Servidor (EC2) ---
resource "aws_instance" "app_server" {
  # Usa o ID da imagem encontrada na pesquisa lá em cima
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name      = "foodapp-key"

  vpc_security_group_ids = [aws_security_group.foodapp_sg.id]

  # --- A MÁGICA: Script de Instalação Automática ---
  user_data = <<-EOF
              #!/bin/bash

              # --- 0. CRIAÇÃO DE SWAP (SALVA-VIDAS DE MEMÓRIA) ---
              # Isso impede a máquina t2.micro de travar por falta de RAM
              sudo fallocate -l 2G /swapfile
              sudo chmod 600 /swapfile
              sudo mkswap /swapfile
              sudo swapon /swapfile
              echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
              # ---------------------------------------------------

              # 1. Instalar Docker e Docker Compose
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              # 2. Pegar o IP Público atual da AWS automaticamente
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

              # 3. Criar o docker-compose.yml
              cat <<EOT > /home/ubuntu/docker-compose.yml
              version: '3.8'
              services:
                api:
                  image: psgomesdev/foodapp-backend:latest
                  ports:
                    - "8090:8090"
                  restart: always
                  depends_on:
                    - db
                  environment:
                    - JAVA_OPTS=-Xmx400m -Xms200m

                    # Banco de Dados
                    - SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/foodapp?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
                    - SPRING_DATASOURCE_USERNAME=root
                    - SPRING_DATASOURCE_PASSWORD=root

                    # --- CONFIGURAÇÃO MAILERSEND (SMTP) ---
                    - SPRING_MAIL_HOST=smtp.mailersend.net
                    - SPRING_MAIL_PORT=587
                    - SPRING_MAIL_USERNAME=MS_7Q9tU9@test-68zxl27e83m4j905.mlsender.net
                    - SPRING_MAIL_PASSWORD=mssp.MloxXUG.x2p0347px3y4zdrn.Dciq2Bm
                    - SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
                    - SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true
                    - APP_MAIL_FROM=MS_7Q9tU9@test-68zxl27e83m4j905.mlsender.net

                    # Links Dinâmicos (IP AWS)
                    - BASE_PAYMENT_LINK=http://$PUBLIC_IP:3000/pay?orderId=
                    - FRONTEND_BASE_URL=http://$PUBLIC_IP:3000

                    # Stripe e AWS
                    - STRIPE_API_SECRET_KEY=${var.stripe_key}
                    - AWS_ACCESSKEYID=${var.aws_access_key}
                    - AWS_SECRETKEY=${var.aws_secret_key}
                    - AWS_S3_REGION=us-east-2
                    - AWS_S3_BUCKET=foodapp-files
                    - SECRETJWTSTRING=bWV1LWFwcC1mb29kLcOpLW8tbWVsaG9yLWUtZXN0ZS3DqS1vLW1ldS1zZWdyZWRvLXN1cGVyLWxvbmdvLTEyMzQ1

                web:
                  image: psgomesdev/foodapp-frontend:latest
                  ports:
                    - "3000:3000"
                  depends_on:
                    - api
                  restart: always
                  environment:
                    - NEXT_PUBLIC_API_URL=http://$PUBLIC_IP:8090/api

                db:
                  image: mysql:8.0
                  restart: always
                  environment:
                    MYSQL_ROOT_PASSWORD: root
                    MYSQL_DATABASE: foodapp
                  ports:
                    - "3306:3306"
              EOT

              # 4. Iniciar tudo
              sudo docker-compose -f /home/ubuntu/docker-compose.yml up -d
              EOF

  tags = {
    Name = "FoodApp-Server"
  }
}

# --- 4. Outputs (Links finais) ---
output "site_url" {
  value = "http://${aws_instance.app_server.public_ip}:3000"
}

output "api_url" {
  value = "http://${aws_instance.app_server.public_ip}:8090/api/menu"
}