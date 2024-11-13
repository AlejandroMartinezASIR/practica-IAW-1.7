#!/bin/bash

#configuramos para mostrar comandos y finalizar si hay error
set -ex

#importamos el archivo variables
source .env

#Instalamos core
snap install core
snap refresh core

#Eliminamos el certbot
apt remove certbot -y

#Lo instalamos
snap install --classic certbot

#####´
a2dissite default-ssl.conf

systemctl reload apache2

#L
certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive