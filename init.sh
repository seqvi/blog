#!/bin/bash

G="\e[32m"
Y="\e[33m"
R="\e[31m"
NC="\e[0m"

source .env

################# THE FUNCTIONS ###############################################
###############################################################################
# GLOBAL VARS #
init_directories_vars(){
  SECRETS_DIRECTORY=".secrets"
  SECRETS_FILE="secrets.yml"
  CONFIGS_DIRECTORY=".configs"
  DATA_DIRECTORY=".data"
}
init_authelia_vars(){
  HOST_NAME="localhost.local"
  CERT_DETAILS="/C=RU/ST=None/L=None/O=seqvi/CN=$HOST_NAME"
  JWT_SECRET="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 32 --charset alphanumeric | sed -n '/Random Value:/s/Random Value: //p')"
  PG_PASSWD="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 12 --charset ascii | sed -n '/Random Value:/s/Random Value: //p')"
  ENCRYPTION_KEY="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 42 --charset alphanumeric | sed -n '/Random Value:/s/Random Value: //p')"
  SESSION_SECRET="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 32 --charset alphanumeric | sed -n '/Random Value:/s/Random Value: //p')"
  ADMIN_PASSWORD_CLEAR="$(docker run --rm authelia/authelia:latest authelia crypto rand --length 8 --charset ascii | sed -n '/Random Value:/s/Random Value: //p')"
  ADMIN_PASSWORD_HASH="$(docker run --rm authelia/authelia:latest authelia crypto hash generate --password "$ADMIN_PASSWORD_CLEAR" -- | sed 's/Digest: //')"
}
# END GLOBAL VARS #

save_init_params(){  
  cat << EOF > $SECRETS_DIRECTORY/$SECRETS_FILE
host_name: $HOST_NAME
jwt_secret: $JWT_SECRET
session_secret: $SESSION_SECRET
pg_user: $DB_USER
pg_db: $PROJECT_DB
pg_passwd: $PG_PASSWD
pg_connections_string: "User ID=$DB_USER;Password=$PG_PASSWD;Host=postgres;Port=5432;Database=$PROJECT_DB;Pooling=true;Min Pool Size=0;Max Pool Size=100;Connection Lifetime=0;"
encryption_key: $ENCRYPTION_KEY
admin_password: 
  clear: $ADMIN_PASSWORD_CLEAR
  hashed: $ADMIN_PASSWORD_HASH

EOF
  chmod 600 $SECRETS_DIRECTORY/$SECRETS_FILE
}
export_file_secrets(){
  echo "$PG_PASSWD" > $SECRETS_DIRECTORY/db_password
  echo "$ENCRYPTION_KEY" > $SECRETS_DIRECTORY/encryption_key
}
export_authelia_configs(){
  mkdir -p "$CONFIGS_DIRECTORY/authelia"
  sed -e "s|{{SESSION_SECRET}}|$SESSION_SECRET|g" -e "s|{{JWT_SECRET}}|$JWT_SECRET|g" -e "s|{{ENCRYPTION_KEY}}|$ENCRYPTION_KEY|g" configs_templates/authelia_config.yml.template > .configs/authelia/configuration.yml
  sed "s|{{ADMIN_PASSWORD}}|$ADMIN_PASSWORD_HASH|g" configs_templates/authelia_users_database.yml.template > $CONFIGS_DIRECTORY/authelia/users_database.yml
}
create_nginx_certs(){
  mkdir -p "$SECRETS_DIRECTORY/nginx/"  
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SECRETS_DIRECTORY/nginx/nginx-selfsigned.key -out $SECRETS_DIRECTORY/nginx/nginx-selfsigned.crt -subj $CERT_DETAILS
  openssl dhparam -out $SECRETS_DIRECTORY/nginx/dhparam.pem 4096
}
export_nginx_configs(){
  mkdir -p $CONFIGS_DIRECTORY/nginx/snippets
  cp configs_templates/nginx/* $CONFIGS_DIRECTORY/nginx  
  cp configs_templates/nginx/snippets/* $CONFIGS_DIRECTORY/nginx/snippets/
}
purge_persistent_data(){
  rm -rf $SECRETS_DIRECTORY
  mkdir -p $SECRETS_DIRECTORY
  rm -rf $CONFIGS_DIRECTORY
  mkdir -p $CONFIGS_DIRECTORY
  rm -rf $DATA_DIRECTORY
  mkdir -p $DATA_DIRECTORY/postgres
}
################# THE SCRIPT ##################################################
###############################################################################

init_directories_vars
purge_persistent_data

#authelia
init_authelia_vars
export_file_secrets
export_authelia_configs

#nginx
create_nginx_certs
export_nginx_configs

save_init_params
#clear DATA_DIRECTORY
echo -e "$Y ################################$NC"
echo -e "$R CLEAR PASSWORD FOR ADMIN:$NC"
echo -e "$G $ADMIN_PASSWORD_CLEAR $NC"
echo -e "$R IT CAN BE SHOWN ONLY ONCE!$NC"
echo -e "$Y ################################$NC"