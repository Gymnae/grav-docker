#!/bin/bash

set -e

function install() {
if ! [ -e $INSTALL_DIR/index.php -a -e $INSTALL_DIR/bin/grav ]; then
  echo "Required files not found in $INSTALL_DIR - Copying from ${SOURCE}..."
  cp -r "$SOURCE"/grav-admin/. $INSTALL_DIR
  chown -R nginx:www-data $INSTALL_DIR
  echo "Done."
fi
}

function configure_admin() {
    export GRAV_HOME=/var/www/localhost/htdocs/

    # Setup admin user (if supplied)
    if [ -z $ADMIN_USER ]; then
        echo "[ INFO ] No Grav admin user details supplied"
    else
        if [ -e $GRAV_HOME/user/accounts/$ADMIN_USER.yaml ]; then
            echo "[ INFO ] Grav admin user already exists"
        else
            echo "[ INFO ] Setting up Grav admin user"
            cd $GRAV_HOME

            sudo -u nginx /usr/bin/php bin/plugin login newuser \
                 --user=${ADMIN_USER} \
                 --password=${ADMIN_PASSWORD-"Pa55word"} \
                 --permissions=${ADMIN_PERMISSIONS-"b"} \
                 --email=${ADMIN_EMAIL-"admin@domain.com"} \
                 --fullname=${ADMIN_FULLNAME-"Administrator"} \
                 --title=${ADMIN_TITLE-"SiteAdministrator"}
        fi
    fi
}

function configure_nginx() {
echo "[ INFO ] Configuring Nginx"

 if [ -z ${DOMAIN} ]; then
        echo "[ INFO ]  > No Domain supplied. Not updating server config"
 else
  echo "[ INFO ]  > Setting server_name to" ${DOMAIN} www.${DOMAIN}
        sed -i 's/server_name localhost/server_name '${DOMAIN}' 'www.${DOMAIN}'/g' /etc/nginx/sites-enabled/grav.conf
 fi
}

function start_services() {
mkdir -p /dev/shm/cache/1/29
mkdir -p /dev/shm/cache/1/30
echo "[ INFO ] Starting nginx"
bash -c '/usr/sbin/php-fpm7 ; /usr/sbin/nginx -g "daemon off;"'
}

function main() {
    install
    configure_admin
    configure_nginx
    start_services
}

main "$@"
