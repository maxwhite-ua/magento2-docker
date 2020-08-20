#!/bin/sh

magento_admin_username="admin"
magento_admin_password="adminqwe123"
magento_admin_email="admin@admin.com"
magento_admin_firstname="Admin"
magento_admin_lastname="User"
magento_baseurl=$APPLICATION_PROTOCOL$APPLICATION_DOMAIN"/"

db_name=$MYSQL_DATABASE
db_user=$MYSQL_USER
db_password=$MYSQL_PASSWORD

if [ ! -z $MAGENTO_ADMIN_USERNAME ];
then
	magento_admin_username=$MAGENTO_ADMIN_USERNAME
fi

if [ ! -z $MAGENTO_ADMIN_PASSWORD ];
then
	magento_admin_password=$MAGENTO_ADMIN_PASSWORD
fi

if [ ! -z $MAGENTO_ADMIN_EMAIL ];
then
	magento_admin_email=$MAGENTO_ADMIN_EMAIL
fi

if [ ! -z $MAGENTO_ADMIN_FIRSTNAME ];
then
	magento_admin_firstname=$MAGENTO_ADMIN_FIRSTNAME
fi

if [ ! -z $MAGENTO_ADMIN_LASTNAME ];
then
	magento_admin_lastname=$MAGENTO_ADMIN_LASTNAME
fi

echo "Clean Magento dirs"
rm -rf ${MAGENTO_ROOT}/generated/*
rm -rf ${MAGENTO_ROOT}/pub/static/*
rm -rf ${MAGENTO_ROOT}/var/cache/*
rm -rf ${MAGENTO_ROOT}/app/etc/config.php
rm -rf ${MAGENTO_ROOT}/app/etc/env.php

echo "Run Magento installation"
php ${MAGENTO_ROOT}/bin/magento setup:install --admin-user=$magento_admin_username --admin-password=$magento_admin_password \
    --admin-email=$magento_admin_email --admin-firstname=$magento_admin_firstname \
    --admin-lastname=$magento_admin_lastname --db-host=mysql --db-user=$db_user \
    --db-name=$db_name --db-password=$db_password --base-url=$magento_baseurl \
    --backend-frontname=admin \
    --cache-backend=redis --cache-backend-redis-server=redis_cache --cache-backend-redis-db=0 \
    --page-cache=redis --page-cache-redis-server=redis_cache --page-cache-redis-db=1 --page-cache-redis-compress-data=1 \
    --session-save=redis --session-save-redis-host=redis_cache --session-save-redis-log-level=3 --session-save-redis-db=2 \
    --elasticsearch-host=elasticsearch --cleanup-database --magento-init-params="MAGE_MODE=${MAGENTO_MODE}"
 
#echo "Set Developer mode"
#php ${MAGENTO_ROOT}/bin/magento deploy:mode:set ${MAGENTO_MODE}

# echo "Set Caching Application to Varnish"
# php ${MAGENTO_ROOT}/bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2

# echo "Set Admin Session Lifetime"
# php ${MAGENTO_ROOT}/bin/magento config:set admin/security/session_lifetime 31536000

# echo "Set Catalog Search to ElasticSearch"
# php ${MAGENTO_ROOT}/bin/magento config:set catalog/search/engine elasticsearch
# php ${MAGENTO_ROOT}/bin/magento config:set catalog/search/elasticsearch6_server_hostname elasticsearch
# php ${MAGENTO_ROOT}/bin/magento config:set catalog/search/elasticsearch6_server_port 9200
# php ${MAGENTO_ROOT}/bin/magento config:set catalog/search/elasticsearch6_index_prefix magento2

echo "Start Reindex"
php ${MAGENTO_ROOT}/bin/magento indexer:reindex