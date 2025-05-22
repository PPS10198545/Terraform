provider "aws" {
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Crear el Security Group
resource "aws_security_group" "web_sg" {
  name        = "ra52-web-sg"
  description = "Permitir SSH, HTTP y HTTPS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Permitir SSH desde cualquier IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Permitir HTTP desde cualquier IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Permitir HTTPS desde cualquier IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RA52-SG"
  }
}

# Crear instancia con SG
resource "aws_instance" "webserver" {
  ami                    = "ami-0c1ac8a41498c1a9c" # Ubuntu 24.04 en Estocolmo
  instance_type          = "t3.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "RA52-WebServer"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ../ansible/ip.txt"
  }
}

