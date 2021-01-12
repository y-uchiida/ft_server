# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    start.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: yoguchi <yoguchi@student.42tokyo.jp>       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/31 07:53:31 by yoguchi           #+#    #+#              #
#    Updated: 2021/01/02 05:09:34 by yoguchi          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#! /usr/bin/bash

if [ $NGINX_AUTOINDEX = off ]; then \
	cp ./nginx_autoindex_off.conf /etc/nginx/conf.d/default.conf; \
else \
	cp ./nginx_default.conf /etc/nginx/conf.d/default.conf; \
fi



# ---------------------------------------- #
# keep container running
# ---------------------------------------- #

service php7.3-fpm start
service nginx start
service mysql start
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log