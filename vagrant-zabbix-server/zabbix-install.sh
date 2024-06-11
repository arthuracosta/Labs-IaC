#!/bin/bash

# Instale o repositório Zabbix
sudo apt update -y

sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
sudo apt update -y

# Instale o servidor, o frontend e o agente Zabbix
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# Instale o Mysql
sudo apt install mysql-server -y

# Criar banco de dados inicial
sudo mysql -u root --password='' <<SCRIPT
CREATE DATABASE zabbix character set utf8mb4 collate utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'senha123';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
QUIT;
SCRIPT

# Importe o schema inicial e os dados
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix zabbix --password senha123

# Desative log_bin_trust_function_creators após importar o schema
sudo mysql -u root --password='' <<SCRIPT
SET GLOBAL log_bin_trust_function_creators = 0;
QUIT;
SCRIPT

# Configure o banco de dados para o servidor Zabbix
sudo echo "DBPassword=senha123" >> /etc/zabbix/zabbix_server.conf

# Inicie o servidor Zabbix e os processos do agente
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

