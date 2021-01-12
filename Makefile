NAME = ft_server_y-uchiida
NGINX_AUTOINDEX = on

default: help

build:
	@echo build image $(NAME) ...
	docker build -t $(NAME) ./

rm_image:
	@if [ $(shell docker image ls -q ${NAME}) ]; then \
	 	echo remove docker image $(NAME)... ; \
		docker image rm $(NAME); \
	else \
	 	echo docker image $(NAME) is not exist. ; \
	fi

rebuild: stop rm_container rm_image build

run:
	@if [ $(shell docker image ls -q ${NAME}) ]; then \
	 	echo docker image exist. ; \
	else \
	 	echo docker image $(NAME) is not exist. ; \
		echo \"make build\" to create docker image. ; \
	fi

	@if [ $(shell docker ps -q -f name=${NAME}) ]; then \
		echo docker container $(NAME) is running. ; \
	elif [ $(shell docker ps -qa -f name=${NAME}) ]; then \
		echo docker container $(NAME) is stopped. restart... ; \
		docker restart $(NAME); \
	else \
		echo create new container... ; \
		if [ $(NGINX_AUTOINDEX) = off ]; then \
			echo nginx autoindex will disable.; \
		fi; \
		docker run --name $(NAME) -e NGINX_AUTOINDEX=$(NGINX_AUTOINDEX) -it -d -p 8080:80 -p 443:443 $(NAME) /bin/bash; \
 	fi

stop:
	@if [ $(shell docker ps -q -f name=${NAME}) ]; then \
		echo stop container $(NAME)...; \
		docker stop $(NAME); \
	else \
 	    echo running contaier is not exist. ; \
 	fi

exec: run
	@docker exec -it $(NAME) /bin/bash

rm_container: stop
	@if [ $(shell docker ps -qa -f name=${NAME}) ]; then \
		echo remove container $(NAME)...; \
		docker rm $(NAME); \
	else \
		echo contaier $(NAME) is not exist.; \
 	fi

autoindex-on: rm_container
	@ echo container create with nginx-autoindex enable...
	@ docker run --name $(NAME) -e NGINX_AUTOINDEX=on -it -d -p 8080:80 -p 443:443 $(NAME) /bin/bash; \

autoindex-off: rm_container
	@ echo container create with nginx-autoindex disabele...
	@ docker run --name $(NAME) -e NGINX_AUTOINDEX=off -it -d -p 8080:80 -p 443:443 $(NAME) /bin/bash; \

open_local:
	@if type firefox > /dev/null 2>&1; then \
		exec firefox ./srcs/public/index.html & \
	else \
		echo firefox command is not exist.; \
		echo please read usage in \"make help\". ; \
	fi

open:
	@if type firefox > /dev/null 2>&1; then \
		if [ $(shell curl -s -k https://localhost/ -o /dev/null -w '%{http_code}\n') != 200 ]; then \
			echo localhost is not working. check container status.; \
		else \
			echo open https://localhost/ ; \
			exec firefox https://localhost/ & \
		fi \
	else \
		echo firefox command is not exist.; \
		echo please read usage in \"make help\". ; \
	fi

wordpress:
	@if type firefox > /dev/null 2>&1; then \
		if [ $(shell curl -s -k https://localhost/ -o /dev/null -w '%{http_code}\n') != 200 ]; then \
			echo localhost is not working. check container status.; \
		else \
			echo open https://localhost/wordpress/ ; \
			exec firefox https://localhost/wordpress/ & \
		fi \
	else \
		echo firefox command is not exist.; \
		echo please read usage in \"make help\". ; \
	fi

phpmyadmin:
	@if type firefox > /dev/null 2>&1; then \
		if [ $(shell curl -s -k https://localhost/ -o /dev/null -w '%{http_code}\n') != 200 ]; then \
			echo localhost is not working. check container status.; \
		else \
			echo open https://localhost/phpmyadmin/ ; \
			exec firefox https://localhost/phpmyadmin/ & \
		fi \
	else \
		echo firefox command is not exist.; \
		echo please read usage in \"make help\". ; \
	fi

clean: stop rm_container rm_image

.PHONY:
	default
	help
	build
	rebuild
	rm_image
	run
	stop
	exec
	open_local
	open
	rm_container
	wordpress
	phpmyadmin
	clean

help:
	@echo below targets you can use as sub-commands...
	@echo - build
	@echo --  build docker image as \"$(NAME)\".
	@echo

	@echo - rebuild
	@echo --  build docker image after removing current image.
	@echo

	@echo - rm_image
	@echo --  remove image \"$(NAME)\".
	@echo

	@echo - run [NGINX_AUTOINDEX=off]
	@echo --  create container \"$(NAME)\".
	@echo --  if a stopped container exist, restart it.
	@echo --  if a option \"NGINX_AUTOINDEX=off\" was set, nginx config change autoindex disable.
	@echo

	@echo - stop
	@echo --  stop a runnning container \"$(NAME)\".
	@echo
	
	@echo - exec
	@echo --  connect /bin/bash to container \"$(NAME)\".
	@echo --  if a container not exist or stopped, it will create or restart before connecting.
	@echo
	
	@echo - autoindex-on
	@echo --  re-create container with nginx autoindex config engable.
	@echo --  this command force container remove.
	@echo

	@echo - autoindex-off
	@echo --  container re-make with nginx autoindex config disable.
	@echo --  this command force container remove.
	@echo

	@echo - open_local
	@echo --  open top page file on firefox with file:// protcol \(as local file\).
	@echo

	@echo - open
	@echo --  open top page of localhost on firefox.
	@echo --  if not localhost\(container\) runnning, show massage.
	@echo

	@echo - wordpress
	@echo --  open wordpress on firefox.
	@echo --  if not localhost\(container\) runnning, show massage.
	@echo

	@echo - phpmyadmin
	@echo --  open phpmyadmin on firefox.
	@echo --  if not localhost\(container\) runnning, show massage.
	@echo

	@echo - clean
	@echo --  remove dokcer container and docker image \"$(NAME)\".
	@echo
