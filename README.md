# Znuny 6.1.2

### Criar imagem com a ultima versão
	docker build -t znuny:6.1.2 --build-arg VERSION=6.1.2 .

### Para rodar o container, digite:
	docker run -d --name znuny -p 80:80 -p 443:443 znuny:6.1.2

### Para atualizar a versão, copie o arquivo 'Config.pm' de dentro do container para um lugar no host.

	mkdir -p /opt/docker/znuny
	docker cp znuny:/opt/otrs/Kernel/Config.pm /opt/container/znuny/Config.pm

Se for apenas atualizar das versões 6.1.0 ou 6.1.2, adicione a variavel "-e ZNUNY_UPDATE=yes"

Para atualizar da versão 6.0, adicione a variavel "-e ZNUNY_UPGRADE=yes"

	docker run -d --name znuny -p 80:80 -p 443:443 -e ZNUNY_UPGRADE=yes \
	-v /opt/container/znuny/Config.pm:/opt/otrs/Kernel/Config.pm znuny:6.1.2

### Para criar o banco de dados, acesse o servidor e digite:
	CREATE DATABASE znuny CHARACTER SET = 'utf8' COLLATE = 'utf8_general_ci';
	GRANT ALL ON znuny.* TO 'znuny'@'%' IDENTIFIED BY 'znuny';

Adicione essas configurações no arquivo conf.d/znuny.cnf do banco de dados (MariaDB ou MySQL)

	[mysqld]
	max_allowed_packet = 64MB
	innodb_log_file_size = 256MB
 
### Backup e Restore
Backup direto do banco de dados

	mysqldump -u znuny -pznuny --add-drop-database --databases znuny | gzip > /tmp/znuny.sql.gz

Para restaurar direto no banco de dados

	gunzip < znuny.sql.gz | mariadb -u znuny -pznuny

Criar uma rotina de backup full todos os dias as 5:00 da manhã e deletar os backup com mais de 8 dias.

Adicionar no crontab do container:

	05 05 * * * /opt/otrs/scripts/backup.pl -d /opt/backups/ -c gzip -r 8 -f fullbackup
