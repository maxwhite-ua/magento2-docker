FROM php:7.4-fpm-alpine

# Maintainer
LABEL mainteiner=maxwhite.nemetc@gmail.com

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        mysql-client \
        freetype-dev \
        icu-dev \
        libmcrypt-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxslt-dev \
        libzip-dev \
        curl \
        zip \
        bash \
        vim \
        git

# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
RUN apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ 

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install intl  -j$(nproc) xsl gd zip pdo_mysql opcache soap bcmath json iconv sockets

RUN sed -i 's/pm.max_children = 5/pm.max_children = 6/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 4/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 2/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 5/' /usr/local/etc/php-fpm.d/www.conf \
    && touch /usr/local/etc/php/conf.d/magento.ini && echo 'memory_limit=2048M' >> /usr/local/etc/php/conf.d/magento.ini \
    && echo 'cgi.fix_pathinfo=0' >> /usr/local/etc/php/conf.d/magento.ini

# Get composer installed to /usr/local/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

VOLUME /root/.composer/cache

ENV MAGENTO_ROOT /var/www/magento2

COPY config/ /docker/config

COPY scripts/ /docker/scripts

RUN sed -i $'s/\r$//' /docker/scripts/* && chmod ug+rx /docker/scripts/*

WORKDIR ${MAGENTO_ROOT}

ENTRYPOINT ["/docker/scripts/entrypoint"]

CMD ["php-fpm", "-R"]