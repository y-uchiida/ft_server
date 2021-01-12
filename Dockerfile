# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: yoguchi <yoguchi@student.42tokyo.jp>       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/27 09:26:40 by yoguchi           #+#    #+#              #
#    Updated: 2021/01/02 04:47:42 by yoguchi          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

LABEL maintainer="yoguchi(y-uchiida)<yoguchi@student.42tokyo.jp>"

# ---------------------------------------- #
# installing packages
# ---------------------------------------- #
RUN  apt-get update \
&&   apt-get install --no-install-recommends -y \
     mariadb-client mariadb-server \
     nginx php-fpm php-mysql php-dev php-gd php-pear php-zip php-xml php-curl php-mbstring \
     wget unzip vim \
  	 openssl \
\
&&   apt-get -y clean \
&&   rm -rf /var/lib/apt/lists/*

# ---------------------------------------- #
#  copy source files into container
# ---------------------------------------- #
WORKDIR /tmp/
COPY ./srcs/start.sh ./
COPY ./srcs/wp-config.php ./wp-config.php
COPY ./srcs/phpmyadmin.inc.php ./phpmyadmin.inc.php
COPY ./srcs/nginx.conf ./nginx.conf
COPY ./srcs/nginx_default.conf ./nginx_default.conf
COPY ./srcs/nginx_autoindex_off.conf ./nginx_autoindex_off.conf
COPY ./srcs/public ./public

# ---------------------------------------- #
# wordpress
# ---------------------------------------- #
RUN mv public /var/www/ \
&&  wget --no-check-certificate https://ja.wordpress.org/wordpress-5.6-ja.tar.gz \
&&  tar -xvzf wordpress-5.6-ja.tar.gz \
&&  rm -rf wordpress-5.6-ja.tar.gz \
&&  mv wordpress /var/www/public/wordpress \
&&  mv wp-config.php /var/www/public/wordpress \
\
# ---------------------------------------- #
# phpmyadmin
# ---------------------------------------- #
&&  wget --no-check-certificate  https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
&&  tar -xvzf phpMyAdmin-5.0.2-all-languages.tar.gz \
&&  rm phpMyAdmin-5.0.2-all-languages.tar.gz \
&&  mv phpMyAdmin-5.0.2-all-languages /var/www/public/phpmyadmin \
&&  mv phpmyadmin.inc.php /var/www/public/phpmyadmin/config.inc.php \
\
# ---------------------------------------- #
# mysql
# ---------------------------------------- #
&&  service mysql start \
&&  echo "UPDATE mysql.user SET Plugin = 'mysql_native_password' WHERE User = 'root';" | mysql -u root --skip-password \
&&  echo "CREATE DATABASE wp_ftserver;" | mysql -u root --skip-password \
&&  echo "CREATE USER wp_user@localhost IDENTIFIED BY 'wp_user'" | mysql -u root --skip-password \
&&  echo "GRANT ALL PRIVILEGES ON wp_ftserver.* TO 'wp_user'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password \
&&  echo "UPDATE mysql.user SET plugin='mysql_native_password' WHERE user='wp_user';" | mysql -u root --skip-password \
&&  echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password \
&&  rm -f mysql_upgrade* \
\
# ---------------------------------------- #
# nginx
# ---------------------------------------- #
&& update-rc.d nginx defaults \
&& update-rc.d php7.3-fpm defaults \
&& chown -R www-data:www-data /var/www/* \
&& chmod -R 755 /var/www/* \
\
&& mv ./nginx.conf /etc/nginx/nginx.conf \
&& if test $NGINX_AUTOINDEX = off; then \
      cp ./nginx_autoindex_off.conf /etc/nginx/conf.d/default.conf; \
    else \
      cp ./nginx_default.conf /etc/nginx/conf.d/default.conf; \
    fi \
\
&&  mkdir /etc/nginx/ssl \
&&  openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42_Tokyo Tokyo/OU=yoguchi/CN=localhost" \
    -out /etc/nginx/ssl/localhost.crt -keyout /etc/nginx/ssl/localhost.key

# ---------------------------------------- #
# keep container running
# ---------------------------------------- #

ENTRYPOINT ["/bin/bash", "start.sh"]