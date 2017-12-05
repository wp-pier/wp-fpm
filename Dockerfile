FROM php:7.1-fpm-alpine

# install the PHP extensions we need
RUN set -ex                                                              &&\
    apk add --no-cache --virtual .phpext-build-deps                        \
      libjpeg-turbo-dev                                                    \
      libpng-dev;                                                          \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr &&\
    docker-php-ext-install gd mysqli opcache                             &&\
    runDeps="$(                                                            \
      scanelf --needed --nobanner --format '%n#p'                          \
              --recursive /usr/local/lib/php/extensions                    \
        | tr ',' '\n'                                                      \
        | sort -u                                                          \
        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
      )"                                                                 &&\
      apk add --virtual .phpext-run-deps $runDeps                        &&\
      apk del .phpext-build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN {                                            \
      echo 'opcache.memory_consumption=128';     \
      echo 'opcache.interned_strings_buffer=8';  \
      echo 'opcache.max_accelerated_files=4000'; \
      echo 'opcache.revalidate_freq=2';          \
      echo 'opcache.fast_shutdown=1';            \
      echo 'opcache.enable_cli=1';               \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN set -ex                                  &&\
    mkdir -p /var/www/html                   &&\
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html
VOLUME /var/www/html

LABEL name="wppier/wp-fpm"
LABEL version="latest"

# USE ENTRYPOINT FROM BASE IMAGE
# USE CMD FROM BASE IMAGE
