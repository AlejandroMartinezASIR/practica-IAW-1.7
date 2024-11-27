# Practica-01-07
En esta práctica vamos a realizar la administración de un sitio **WordPress** desde el terminal con la utilidad **WP-CLI**
Con **WP-CLI** podemos realizar las mismas tareas que se pueden hacer desde el panel de administración web de **WordPress**, pero desde la línea de comandos.
En esta práctica tendremos 4 directorios:

 - - scripts
   		- .env
   		-  install_lamp.sh
   		-  setup_letsencrypt_https.sh
   		- deploy_wordpress_with_wpcli.sh
   	- conf
   		- 000-default.conf
   	- php
   		- index.php
   	- htaccess
   		- .htaccess

## scripts
Aquí automatizaremos los procesos de instalación y configuración de **WordPress** y **WP**.
## .env
Variables
   
    LE_EMAIL=PRACTICA1.7@prueba.com
    LE_DOMAIN=practica-wordpress.ddnsking.com
    #variables wordpress
    WORDPRESS_DB_NAME=wordpress
    WORDPRESS_DB_USER=alex
    WORDPRESS_DB_PASSWORD=1234
    IP_CLIENTE_MYSQL=localhost
    WORDPRESS_DB_HOST=localhost
    ###PAGINA
    WORDPRESS_DIRECTORY=/var/www/html
    CERTIFICATE_DOMAIN=practica-wordpress.ddnsking.com
    WORDPRESS_TITLE="Blog de IAW"
    WORDPRESS_USER=admin
    WORDPRESS_PASSWORD=admin
    WORDPRESS_EMAIL=demo@demo.es
    WORDPRESS_HIDE_LOGIN_URL="nadaimportante"
    
### install_lamp.sh
Muestra todos los comandos que se van ejecutando

    set -ex

Actualizamos los repositorios

    apt update

Actualizamos los paquetes 

    apt upgrade -y

Instalamos el servidor web **Apache**

    apt install apache2 -y

Habilitamos el modulo rewrite

    a2enmod rewrite

Copiamos la configuración predeterminada del servidor

    cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf


Instalamos **PHPMyAdmin**

    sudo apt install php libapache2-mod-php php-mysql -y

Reiniciamos servicio

    systemctl restart apache2

Instalamos  el sistema gestor de datos **MySQL**

    apt install mysql-server -y

Modificamos el propietario

    chown -R www-data:www-data /var/www/html

Después de habilitar el módulo deberá reiniciar el servicio de Apache.

    systemctl restart apache2
    a2ensite 000-default.conf


### setup_letsencrypt_https.sh
Muestra todos los comandos que se van ejecutando

    set  -ex

Ponemos las variables del archivo *.env*

    source  .env


Instalamos y actualizamos **Snap**

    snap  install  core

    snap  refresh  core

  

Eliminamos cualquier instalación previa de **Certbot** con **apt**

    apt  remove  certbot -y

  

Instalamos la aplicación **Certbot**

    snap  install  --classic  certbot
    a2dissite default-ssl.conf
  
Obtenemos el certificado y configuramos el servidor web **Apache**

Ejecutamos el comando **Certbot**

    certbot  --apache  -m  $LE_EMAIL  --agree-tos  --no-eff-email  -d  $LE_DOMAIN  --non-interactive


### deploy_wordpress_with_wpcli.sh
Muestra todos los comandos que se van ejecutando

    set -ex

Actualizamos los repositorios

    apt update

Actualizamos los paquetes 

    apt upgrade -y

Ponemos las variables del archivo *.env*

    source .env

Borramos instalaciones previas de **wp-cli**

    rm -rf /tmp/wp-cli.phar

Descargamos el archivo *wp-cli.phar* del repositorio oficial de **WP-CLI.** 

    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 

Le asignamos permisos de ejecución al archivo *wp-cli.phar*.

    chmod +x wp-cli.phar

Movemos el archivo *wp-cli.phar* al directorio */usr/local/bin/* con el nombre **wp** para poder utilizarlo sin necesidad de escribir la ruta completa donde se encuentra.

    mv wp-cli.phar /usr/local/bin/wp

Eliminamos instalaciones revias de **WordPress**

    rm -rf /var/www/html/*

Descargamos el código fuente de **WordPress** en */var/www/html*

    wp core download --locale=es_ES --path=/var/www/html --allow-root 

Creamos la base de datos y el usuario de la base de datos

    mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
    mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
    mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
    mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
    mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

Creamos el archivo *wp-config*

    wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=localhost \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

Instalamos el **WordPress** con variables personalizadas

    wp core install \
     --url=$LE_DOMAIN \
     --title="$WORDPRESS_TITLE" \
     --admin_user=$WORDPRESS_USER \
     --admin_password=$WORDPRESS_PASSWORD \
     --admin_email=$WORDPRESS_EMAIL \
     --path=$WORDPRESS_DIRECTORY \
     --allow-root 

Pondremos la pagina de configuracion de la maquina

    wp option update whl_page "$WORDPRESS_HIDE_LOGIN_URL" --path=/var/www/html --allow-root

Enlaces permanentes

    wp rewrite structure '/%postname%/' --path=$WORDPRESS_DIRECTORY --allow-root


Copiamos el htaccess 

    cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY

Cambiamos el propietario

    sudo chown -R www-data:www-data $WORDPRESS_DIRECTORY
