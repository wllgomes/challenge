**AWS Infrastructure with Terraform**

**Descrição**

Este projeto configura uma infraestrutura completa na AWS utilizando Terraform. A infraestrutura inclui um servidor EC2 com Nginx para servir uma página web estática e um banco de dados RDS MySQL para suportar uma ferramenta de monitoramento.

**Tecnologias utilizadas**

Terraform: Para gerenciar e provisionar a infraestrutura como código.

AWS: Serviços utilizados incluem EC2, RDS, VPC, Subnet, Security Groups e Internet Gateway.

Ubuntu Server 22.04 LTS: Sistema operacional configurado no EC2.

Nginx: Servidor web para hospedar uma página HTML estática.

MySQL: Banco de dados utilizado no RDS.

**Instalação e uso**

**Pré-requisitos**

Terraform instalado na máquina local.

Uma conta na AWS com as credenciais configuradas localmente (variáveis de ambiente AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY).

**Passos para configurar a infraestrutura**

Clone o repositório:

git clone https://github.com/wllgomes/challenge.git

cd challenge

Inicialize o Terraform:

terraform init

Valide os arquivos de configuração:

terraform validate

Crie o plano de execução:

terraform plan -ou=tfplan

Aplicamos o plano para provisionar a infraestrutura:

terraform apply -auto-approve tfplan

Resultados esperados

O IP público da instância EC2 será exibido como saída.

O endpoint do banco de dados RDS será exibido como saída.
