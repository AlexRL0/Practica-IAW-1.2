# Practica-IAW-1.2- Instalación de LAMP Stack en RHEL

## Pasos previos a la instalación

**para la instalación vamos a tener que crear la siguiente estructura de directorios y archivos:**

![](imagenes/Directorio-practica-1.2.png)

**Una vez creados los archivos y directorios, procedemos a la instalación de las herramientas.**

## Instalación de LAMP Stack en RHEL

## 1. Creación del archivo `install_lamp.sh` para la automatización del proceso de instalación

### Actualizamos los paquetes del sistema y mostramos los comandos que se van ejecutando. 

```
dnf update -y
```

> [!NOTE]  
> En Red Hat, par la instalación de paquetes y actualizaciones, se utiliza la herramienta `dnf`

```
set -ex
```

## 1.1 Instalación del Servidor web Apache

### Paso 1: Instalamos el servidor web Apache

```
dnf install httpd -y
```

### Paso 2: Iniciamos el servicio de Apache

```
systemctl start httpd
```

### Paso 3: Habilitamos el servicio para que se inicie automaticamente despues de cada reinicio

```
systemctl enable httpd
```

## 1.2 Instalación de MySQL Server

### Paso 1: Instalamos MYSQL server

```
dnf install mysql-server -y
```

### Paso 2: Iniciamos el servicio de Mysql

```
systemctl start mysqld
```

### Paso 3: Habilitamos el servicio para que se inicie automaticamente despues de cada reinicio 

```
systemctl enable mysqld
```

## 1.3 Instalación de el interprete de PHP

### Paso 1: Instalamos el interprete de PHP

```
dnf install php -y
```

### Paso 2: Instalamos la extensión para que PHP pueda conectar con MySQL

```
dnf install php-mysqlnd -y
```

### Paso 3: Reinciamos el servicio de Apache

```
systemctl restart httpd
```

### Paso 4: Copiamos el index.php de prueba en /var/www/html

```
cp ../php/index.php /var/www/html
```

---
## 2. Creación del archivo `install_tools.sh` para la automatización del proceso de instalación

### Importamos el archivo de variables

```
source .env
```

> [!NOTE]  
> Este archivo de configuración se hace para que lo que vamos a hacer mas adelante reconozca las variables configuradas en ese archivo. Todas las variables que aparezcan en este documento, están dentro del archivo `.env`

> [!WARNING]  
> Otra cosa a tener en cuenta es que este archivo es publico en el repositorio y pues toda la gente que vea el repositorio puede ver las contraseñas y usuarios que tiene el archivo, asi que para evitar eso, hacemos un archivo `.gitignore` y dentro de él ponemos `.env` para que ignore ese archivo para que a la hora de subirlo esté oculto al público. Lo que podemos hacer para que la gente sepa que variables se configuran podemos hacer un `.env.example` y dentro poner las variables vacías para que sepan que se tienen que configurar con un .env.

### Actualizamos los paquetes del sistema y mostramos los comandos que se van ejecutando 

```
dnf update -y
```

```
set -ex
```

## 2.1 Instalamos las dependencias necesarias para phpmyadmin

```
dnf install php-mbstring php-zip php-json php-gd php-fpm php-xml -y
``` 

**Después de este comando, reiniciamos el servicio de apache con el comando:**

**`systemctl restart httpd`**

## 2.2 Instalacion de wget

### Paso 1: Instalamos la utilidad wget

```
dnf install wget -y
```

> [!NOTE]  
> Esta utilidad nos la descargamos ya que nos hace falta para poder descargar el código fuente de `phpmyadmin`.

### Paso 2: Descargamos el código fuente de phpmyadmin en /var/www/html

```
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -P /var/www/html
```

> [!TIP]  
> Con el parámetro `-P` podemos indicar la ruta donde queremos guardar el archivo que nos descarguemos con la utilidad `wget`, en mi caso, lo he guardado en la ruta `/var/www/html`.

### Paso 3: Descomprimimos el archivo anterior

```
tar xvf /var/www/html/phpMyAdmin-latest-all-languages.tar.gz -C /var/www/html
```

### Paso 4: Eliminamos el archivo tar.gz

```
rm /var/www/html/phpMyAdmin-latest-all-languages.tar.gz
```

### Paso 4: Eliminamos instalaciones previas de phpmyadmin

```
rm -rf /var/www/html/phpmyadmin
```

> [!IMPORTANT]  
> Esto lo hacemos para que a la hora de ejecutar el archivo para que haga todo automáticamente no haya conflictos con los archivos y se pueda alojar en la ruta sin problemas de duplicidad.

### Paso 5: Renombramos el nombre del directorio de phpmyadmin

```
mv /var/www/html/phpMyAdmin-5.2.1-all-languages/ /var/www/html/phpmyadmin
```

> [!TIP]  
> Es recomandable renombrar el directorio ya que el nombre original es muy largo y a veces eso puede provocar problemas, asi que para evitar sustos, le cambiamos el nombre a `phpmyadmin`.

### Paso 6: Modificamos el propietario y el grupo del directorio

```
chown -R apache:apache /var/www/html/phpmyadmin
```

> [!NOTE]  
> Esto lo hacemos ya que hay que darle permisos al usuario de apache para que pueda leer el archivo del directorio, ya que si no lo hacemos, phpmyadmin no funcionará.

## 2.3 Configuración de PHPMyAdmin

Para configurar `phpmyadmin` hay que realizar lo siguiente:

* Configurar el archivo de configuración `config.inc.php`.
* Configuración de la base de datos para `phpMyAdmin`.  
    * Creación de la base de datos.
    * Creación de un usuario para la base de datos.

### Paso 1: Creamos el archivo de configuración de phpMyAdmin

```
cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
```

> [!IMPORTANT]  
> El siguiente paso que haríamos sería modificar manualmente el archivo con `nano`, pero como estamos haciendo este archivo para que todo se automatize al ejecuartase,lo haremos todo en el archivo `install_tools.sh`. Las variables a configurar son las siguientes:
>* `$cfg['blowfish_secret']`: En esta variable hay que configurar un valor aleatorio de 32 caracteres que se utiliza como clave secreta para cifrar las cookies de sesión de phpMyAdmin.
>
>* `$cfg['TempDir']`: Y esta variable lo que hace es configurar un directorio temporal.

### Paso 2: Creamos la base de datos de phpMyAdmin

```
mysql -u root < /var/www/html/phpmyadmin/sql/create_tables.sql
```

### Paso 3: Creamos un usuario para phpMyAdmin

```bash
mysql -u root <<< "DROP USER IF EXISTS $PMA_USER@'%'"
mysql -u root <<< "CREATE USER $PMA_USER@'%' IDENTIFIED BY '$PMA_PASS'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $PMA_DB.* TO $PMA_USER@'%'"
```

### Paso 4: Generamos un valor aleatorio de 32 caracteres para la variable blowfish_secret

```
RANDOM_VALUE=`openssl rand -hex 16`
```

> [!IMPORTANT]  
> Esto lo hacemos para que luego al cambiar el valor de la variable `blowfish_secret` se genere una clave aleatoria de 32 caracteres cada vez que ejecutemos este comando y lo implemente dentro de la variable.

### Paso 5: Modificamos la variable blowfish_secret en el archivo de configuración

```
sed -i "s/\(\$cfg\['blowfish_secret'\] =\).*/\1 '$RANDOM_VALUE';/" /var/www/html/phpmyadmin/config.inc.php
```

> [!NOTE]  
> El comando `sed` se utiliza para modificar y eliminar texto en un archivo. A continuación voy a explicar los parámetros que se han utilizado en el ejemplo anterior.  
>* `i`: Indica que queremos que los cambios se apliquen directamente en el archivo que se pasa como parámetro. Si no se utilizase este paráemtro, los cambios se mostrarían por la salida estándar pero el archivo no se modificaría.
>
>* `s/cadena_a_buscar/cadena_de_reemplazo/`: Esta sintaxis es la que se utiliza para buscar y reemplazar texto en un archivo. En este caso, se busca la cadena `$cfg['blowfish_secret'] =` y se reemplaza por la cadena `$cfg['blowfish_secret'] = '$RANDOM_VALUE';`.
>
>* `\1 '$RANDOM_VALUE';`. El número `\1` quiere decir que se debe poner el patrón que hemos buscado, es decir, se pondrá `$cfg['blowfish_secret'] =` seguido del contenido de la variable `$RANDOM_VALUE`.

### Paso 6: Añadimos la configuración del directorio temporal

```
sed -i "/blowfish_secret/a \$cfg\['TempDir'\] = '/tmp';" /var/www/html/phpmyadmin/config.inc.php 
```

> [!IMPORTANT]  
> Para configurar esta variable vamos a utilizar el modificador `a` que permite añadir texto después de una línea que coincida con lo que estamos buscando.

## 2.4 Instalacion de Adminer

### Paso 1: Creamos un directorio para adminer

```
mkdir -p /var/www/html/adminer
```

### Paso 2: Instalamos Adminer

```
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer
```

### Paso 3: Renombramos el nombre del script de Adminer

```
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php
```

> [!TIP]  
> Renombramos el directorio ya que el nombre que tiene es muy largo y lo cambiamos a uno mas común con el archivo del `index.php` para que el servidor apache lo pueda reconocer más fácil.

### Paso 4. Modificamos el propietario y el grupo del archivo

```
chown -R www-data:www-data /var/www/html/adminer
```

**Una vez más tenemos que darle permisos al grupo y usuario de apache para que pueda leer el archivo.**

### Paso 5: comprobación de que la página `adminer` funciona

![](imagenes/adminer.png)
