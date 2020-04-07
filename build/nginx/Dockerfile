FROM nginx:stable-alpine

LABEL mainteiner=maxwhite.nemetc@gmail.com

ARG MAGE_HOST

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        openssl \
    && openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=${MAGE_HOST}" -addext "subjectAltName=DNS:${MAGE_HOST}" -newkey rsa:2048 -keyout /etc/ssl/private/${MAGE_HOST}.key -out /etc/ssl/certs/${MAGE_HOST}.crt \
    && openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=pwa-${MAGE_HOST}" -addext "subjectAltName=DNS:pwa-${MAGE_HOST}" -newkey rsa:2048 -keyout /etc/ssl/private/pwa-${MAGE_HOST}.key -out /etc/ssl/certs/pwa-${MAGE_HOST}.crt \
    && apk del .build-deps

ENV DOLLAR=$

RUN mkdir -p /var/www

RUN chown -R :www-data /var/www/

COPY conf.d/* /etc/nginx/conf.d/

CMD /bin/sh -c "for file in \`find /etc/nginx/conf.d/*.tmpl\`; do envsubst < \${file%.*}.tmpl > \${file%.*}.conf; done && nginx -g 'daemon off;'"