FROM nginx:stable-alpine

LABEL mainteiner=maxwhite.nemetc@gmail.com

ENV DOLLAR=$

RUN mkdir -p /var/www

RUN chown -R :www-data /var/www/

COPY conf.d/* /etc/nginx/conf.d/

CMD /bin/sh -c "envsubst < /etc/nginx/conf.d/magento.tmpl > /etc/nginx/conf.d/magento.conf && nginx -g 'daemon off;' || cat /etc/nginx/conf.d/magento.conf"