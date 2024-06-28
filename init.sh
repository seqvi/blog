#!/bin/bash
G="\e[32m"
Y="\e[33m"
R="\e[31m"
NC="\e[0m"

#Parameters
secrets_directory=".secrets"
secrets_file="secrets.yml"
configs_directory=".configs"
data_directory=".data"

#Generate JWT
JWT_SECRET="$(openssl rand -base64 32)"
PG_PASSWD="$(openssl rand -base64 12)"
ENCRYPTION_KEY="$(openssl rand -base64 42)"
SESSION_SECRET="$(openssl rand -base64 32)"
ADMIN_PASSWORD_CLEAR="$(openssl rand -base64 12)"
SALT=$(openssl rand -base64 12)
ADMIN_PASSWORD="$(echo "$ADMIN_PASSWORD_CLEAR" | argon2 $SALT -id -t 2 -m 16 -p 4 -e)"
#Create secrets_directory
mkdir -p "$secrets_directory"
echo "$PG_PASSWD" > $secrets_directory/db_password
echo "$ENCRYPTION_KEY" > $secrets_directory/encryption_key

cat << EOF > $secrets_directory/$secrets_file
jwt_secret: $JWT_SECRET
session_secret: $SESSION_SECRET
pg_passwd: $PG_PASSWD
encryption_key: $ENCRYPTION_KEY
admin_password: 
  clear: $ADMIN_PASSWORD_CLEAR
  salt: $SALT
  hashed: $ADMIN_PASSWORD

EOF

#Populate configs with secrets
rm -rf $configs_directory
mkdir -p "$configs_directory"
mkdir -p "$configs_directory/nginx/"
cp configs_templates/nginx_nginx.conf.template $configs_directory/nginx/nginx.conf
mkdir -p "$configs_directory/authelia"
sed -e "s|{{SESSION_SECRET}}|$SESSION_SECRET|g" -e "s|{{JWT_SECRET}}|$JWT_SECRET|g" -e "s|{{ENCRYPTION_KEY}}|$ENCRYPTION_KEY|g" configs_templates/authelia_config.yml.template > .configs/authelia/configuration.yml

sed "s|{{ADMIN_PASSWORD}}|$ADMIN_PASSWORD|g" configs_templates/authelia_users_database.yml.template > $configs_directory/authelia/users_database.yml


#clear data_directory
rm -rf $data_directory
mkdir -p $data_directory

#
echo -e "$R CLEAR PASSWORD FOR ADMIN:$NC"
echo -e "$G $ADMIN_PASSWORD_CLEAR $NC"
echo -e "$R IT CAN BO SHOWN ONLY ONCE!$NC"