#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Paso1. Se importan las variables de configuracion
source .env

#Eliminamos descargas previas de el codigo fuente

rm -rf /tmp/latest.tar.gz

#Descargamos la última versión de WordPress con el comando wget.
wget https://wordpress.org/latest.tar.gz -P /tmp

#Descomprimimos el archivo .tar.gz que acabamos de descargar con el comando tar
tar -xzvf /tmp/latest.tar.gz -C /tmp

#borramos instalaciones previas
rm -rf /var/www/html/*

#El contenido se ha descomprimido en una carpeta que se llama wordpress. Ahora, movemos el contenido de /tpm/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html

#Creamos la base de datos y el usuario para WordPress.
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

#eliminamos copias previas
rm -rf /var/www/html/wp-config.php

#Creamos un archivo de configuración
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#configurar las variables de configuración del archivo de configuración de WordPress.
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

#Cambiamos el propietario y el grupo al directorio
chown -R www-data:www-data /var/www/html/

#Habilitamos el módulo mod_rewrite de Apache.
a2enmod rewrite

#Después de habilitar el módulo deberá reiniciar el servicio de Apache.
sudo systemctl restart apache2
