#! /bin/bash

#Configuramos para mostrar los comandos del script y para que la ejecución se detenga cuando hay un error
set -ex

#Importamos las variables de entorno
source .env

# Actualizamos los paquetes del sistema
dnf update -y

#Instalamos las dependencias necesarias para phpmyadmin
dnf install php-mbstring php-zip php-json php-gd php-fpm php-xml -y

#Reinciamos el servicio de Apache
systemctl restart httpd

#Instalamos la utilidad wget
dnf install wget -y

#Descargamos el código fuente de phpmyadmin en /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -P /var/www/html

#Descomprimimos el archivo anterior
tar xvf /var/www/html/phpMyAdmin-latest-all-languages.tar.gz -C /var/www/html

#Eliminamos el archivo tar.gz
rm /var/www/html/phpMyAdmin-latest-all-languages.tar.gz

#Eliminamos instalaciones previas de phpmyadmin
rm -rf /var/www/html/phpmyadmin

#Renombramos el nombre del directorio de phpmyadmin
mv /var/www/html/phpMyAdmin-5.2.1-all-languages/ /var/www/html/phpmyadmin

#Modificamos el propietario y el grupo del directorio
chown -R apache:apache /var/www/html/phpmyadmin

#Creamos el archivo de configuración de phpMyAdmin
cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php

#Creamos la base de datos de phpMyAdmin
mysql -u root < /var/www/html/phpmyadmin/sql/create_tables.sql