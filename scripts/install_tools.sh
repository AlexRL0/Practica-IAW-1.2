#! /bin/bash

#Configuramos para mostrar los comandos del script y para que la ejecución se detenga cuando hay un error
set -ex

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
tar xvf phpMyAdmin-latest-all-languages.tar.gz -C /var/www/html