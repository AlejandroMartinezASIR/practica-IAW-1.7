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

#Creamos el directorio para la instalacion de wordpress
mkdir -p /var/www/html/$WORDPRESS_DIRECTORY

#El contenido se ha descomprimido en una carpeta que se llama wordpress. Ahora, movemos el contenido de /tpm/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html/$WORDPRESS_DIRECTORY

#Creamos la base de datos y el usuario para WordPress.
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

#eliminamos copias previas
rm -rf /var/www/html/wp-config.php

#Creamos un archivo de configuración
cp /var/www/html/$WORDPRESS_DIRECTORY/wp-config-sample.php /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

#configurar las variables de configuración del archivo de configuración de WordPress.
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

#Cuando realizamos la instalación de WordPress en su propio directorio, es necesario configurar estas dos variables de configuración:
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/$WORDPRESS_DIRECTORY');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN');" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

#Copiamos el archivo /var/www/html/$WORDPRESS_DIRECTORY/index.php a /var/www/html.
cp /var/www/html/$WORDPRESS_DIRECTORY/index.php /var/www/html

#remplazamos
sed -i "s#wp-blog-header.php#$WORDPRESS_DIRECTORY/wp-blog-header.php#" /var/www/html/index.php 

#En primer lugar, eliminamos los valores por defecto de las security keys que aparecen en el archivo de configuración.
sed -i "/AUTH_KEY/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/SECURE_AUTH_KEY/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/LOGGED_IN_KEY/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/NONCE_KEY/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/AUTH_SALT/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/SECURE_AUTH_SALT/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/LOGGED_IN_SALT/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php
sed -i "/NONCE_SALT/d" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

###keys
SECURITY_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
SECURITY_KEYS=$(echo $SECURITY_KEYS | tr / _)


#Añadimos las security keys al archivo de configuración.
sed -i "/@-/a $SECURITY_KEYS" /var/www/html/$WORDPRESS_DIRECTORY/wp-config.php

#Cambiamos el propietario y el grupo al directorio
chown -R www-data:www-data /var/www/html/

a2enmod rewrite

sudo systemctl restart apache2




