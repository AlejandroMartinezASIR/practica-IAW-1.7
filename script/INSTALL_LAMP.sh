#!/bin/bash

#Para mostrar los comandos que son ejecutables con -x, si se pone -ex nos muestra que comando falla
set -ex 

#Poner sudo cuando se vaya a lanzar el script
apt update

#Actualizar los paquetes del sistema
#apt upgrade -y

#Instalamos el servidor web apache y poniendo -y no hace falta escribir nada
apt install apache2 -y

#habilitamos el modulo rewrite
a2enmod rewrite

#Copiamos el 000 default para sustituir el archivo por defecto del sistema
cp ../conf/000-default.conf /etc/apache2/sites-available/

#Instalamos php con los modulos necesarios
sudo apt install php libapache2-mod-php php-mysql -y

#Reiniciamos el servicio de apache2
systemctl restart apache2

#Instalaremos MySQL server
sudo apt install mysql-server -y

#Copiamos nuestro archivo de prueba de PHP en /var/www/html
cp ../php/index.php /var/www/html

#Modificamos el propietario del grupo y de archivo index.php
chown -R www-data:www-data /var/www/html

#Habilitamos el módulo mod_rewrite de Apache.
a2enmod rewrite

#Después de habilitar el módulo deberá reiniciar el servicio de Apache.
systemctl restart apache2


a2ensite 000-default.conf