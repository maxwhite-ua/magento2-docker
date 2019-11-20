FROM maxwhite/magento2-php7.2-fpm-alpine


# Maintainer
LABEL mainteiner=maxwhite.nemetc@gmail.com

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

ENV MAGENTO_ROOT /var/www/magento2

COPY config/ /docker/config

COPY scripts/ /docker/scripts

RUN sed -i $'s/\r$//' /docker/scripts/* && chmod ug+rx /docker/scripts/*

WORKDIR ${MAGENTO_ROOT}

ENTRYPOINT ["/docker/scripts/entrypoint"]

CMD ["php-fpm", "-R"]