FROM gymnae/webserverbase:master
# dockerfile in portion inspired byby evnsio/grav and opsforge/grav-docker

MAINTAINER gymnae
LABEL name="grav-docker"
LABEL version="0.1"

# install the PHP extensions we need
RUN apk-install	\
	php7-gd@community \
	php7-zip@community \
	php7-opcache@community

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
		echo 'upload_max_filesize=128M'; \
		echo 'post_max_size=128M'; \
	} > /etc/php7/conf.d/opcache-recommended.ini

VOLUME /var/www/html

# Set user to www-data
RUN mkdir -p /var/www && chown www-data:www-data /var/www
USER nginx

# Install grav
WORKDIR /var/www
RUN wget https://github.com/getgrav/grav/releases/download/$GRAV_VERSION/grav-admin-v$GRAV_VERSION.zip && \
    unzip grav-admin-v$GRAV_VERSION.zip && \
    rm grav-admin-v$GRAV_VERSION.zip && \
    cd grav-admin && \
    bin/gpm install -f -y admin

# Return to root user
USER root
  
  # Configure nginx with grav
WORKDIR grav-admin
RUN cd webserver-configs && \
    sed -i 's/root \/home\/USER\/www\/html/root \/var\/www\/grav-admin/g' nginx.conf && \
    cp nginx.conf /etc/nginx/

# Set the file permissions
RUN usermod -aG www-data nginx

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh && \
  chown root:root /docker-entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD /usr/sbin/php-fpm7 ; /usr/sbin/nginx -g "daemon off;"
