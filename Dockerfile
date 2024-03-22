FROM php:8.1-apache

ENV MONARC_VERSION=v2.12.6
ENV DB_HOST=db
ENV DB_PORT=3306
ENV DB_USER=monarc
ENV DB_PASSWORD=monarc_password
ENV DB_COMMON_NAME=monarc_common
ENV DB_CLI_NAME=monarc_cli
ENV DB_ROOT_PASSWORD=root_password
ENV APPLICATION_ENV=production
ENV PATH_TO_MONARC=/var/lib/monarc/fo
ENV MONARCFO_RELEASE_URL=https://github.com/monarc-project/MonarcAppFO/releases/download/$MONARC_VERSION/MonarcAppFO-$MONARC_VERSION.tar.gz

RUN apt-get update && apt-get install -y zip unzip git gettext curl gsfonts software-properties-common git mariadb-client vim imagemagick libzip4
# dev dependencies for build
RUN apt-get install -y --no-install-recommends libzip-dev libonig-dev libcurl4-openssl-dev libicu-dev libpng-dev libxml2-dev libmagickwand-dev

RUN git config --global pull.ff only

# Conf apache
RUN a2dismod status && a2enmod ssl && a2enmod rewrite && a2enmod headers

RUN printf "\n" | pecl install imagick apcu
RUN docker-php-ext-install bcmath intl gd pdo_mysql xml mysqli zip mbstring curl && docker-php-ext-enable imagick apcu

#RUN pecl install xdebug
#RUN docker-php-ext-enable xdebug

RUN mkdir -p /var/lib/monarc/releases/
# Download release
RUN curl -sL $MONARCFO_RELEASE_URL -o /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL`
# Create release directory
RUN mkdir /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'`
# Unarchive release
RUN  tar -xzf /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL` -C /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'`
# Create release symlink
RUN ln -s /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'` $PATH_TO_MONARC

# remove archive
RUN rm /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL`

COPY monarc.conf /etc/apache2/sites-available/monarc.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN ln -s /etc/apache2/sites-available/monarc.conf /etc/apache2/sites-enabled/monarc.conf

COPY php.ini /usr/local/etc/php/php.ini
COPY 20-xdebug.ini /etc/php/8.1/apache2/conf.d/20-xdebug.ini

COPY local.php $PATH_TO_MONARC/config/autoload/local.php
COPY initdb.sh /var/lib/monarc/initdb.sh
RUN chmod ugo+x /var/lib/monarc/initdb.sh

#RUN apt-get remove -y libzip-dev libonig-dev libcurl4-openssl-dev libicu-dev libpng-dev libxml2-dev libmagickwand-dev
RUN apt -y autoclean && apt -y autoremove && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD ["sh", "-c", "/var/lib/monarc/initdb.sh; apache2-foreground"]