provider "aws" {
  region = "us-east-1"  
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "main-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "web-security-group"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0a91cd140a1fc148a"  
  instance_type = "t2.micro"               
  subnet_id     = aws_subnet.main.id
  security_groups = [
    aws_security_group.web_sg.name,
  ]

  tags = {
    Name = "web-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y

              # Instalação de pacotes essenciais
              apt-get install -y nginx ufw fail2ban

              # Configuração do firewall UFW
              ufw allow OpenSSH
              ufw allow 'Nginx HTTP'
              ufw --force enable

              # Configuração de Fail2Ban
              systemctl enable fail2ban
              systemctl start fail2ban

              # Página HTML estática
              echo '<h1>Bem-vindo ao meu servidor AWS configurado com Terraform!</h1>' > /var/www/html/index.html
              systemctl restart nginx
              EOF
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
  description = "Endereço IP público da instância EC2"
}

resource "aws_db_instance" "monitoring_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "monitoringdb"
  username             = "admin"
  password             = "securepassword"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]
  skip_final_snapshot  = true

  tags = {
    Name = "monitoring-rds"
  }
}

# Subnet group para o RDS
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.main.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
  description = "Endereço IP público da instância EC2"
}

output "rds_endpoint" {
  value = aws_db_instance.monitoring_rds.endpoint
  description = "Endpoint do banco de dados RDS"
}
