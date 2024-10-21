#! /bin/bash

#Configuramos para mostrar los comandos del script y para que la ejecución se detenga cuando hay un error
set -ex

#Actualizamos los paquetes del sistema
dnf update -y

#Instalamos el servidor web Apache
dnf install httpd -y

#Iniciamos el servicio de Apache
systemctl start httpd

#Habilitamos el servicio para que se inicie automaticamente despues de cada reinicio
systemctl enable httpd

#Intalamos Mysql Server
dnf install mysql-server -y

#Iniciamos el servicio de Mysql
systemctl start mysqld

#Habilitamos el servicio para que se inicie automaticamente despues de cada reinicio 
systemctl enable mysqld

#Instalamos el interprete de PHP
dnf install php -y

#Instalamos la extensión para que PHP pueda conectar con MySQL
dnf install php-mysqlnd -y

#Reinciamos el servicio de Apache
systemctl restart httpd

#Copiamos el index.php de prueba en /var/www/html
cp ../php/index.php /var/www/html