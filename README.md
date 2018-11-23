# boygruv_microservices

## Homework-13
#### Работа с docker-machine

Установка docker-machine
- Mac OS и Windows идет в комплекте с docker (docker-machine -v)
- Linux
https://docs.docker.com/machine/install-machine/

Команды
```sh
## Команда создания
$ docker-machine create <имя>

## Переключение между машинами
$ eval $(docker-machine env <имя>)

## Переключение на локальный докер
$ eval $(docker-machine env --unset)

## Удаление
$ docker-machine rm <имя>
```

Подключаемся к GCP
```sh
## Установим переменную с PROJECT_ID
$ export GOOGLE_PROJECT=<projrct_id>

## Создание виртуалки с docker
$ docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b 
<docker_host_name>

## Просмотр созданных VM
$ docker-machine ls

## Переключение на управление докером на запущенным на GCP
$ eval $(docker-machine env <docker_host_name>)

```
> Изоляция docker на хост машине делается через `user namespace` (https://docs.docker.com/engine/security/userns-remap/)

> Для возможности доступа из контейнера к процессам хост машины надо запустить контейнер с ключем: `--pid host `
```sh
$ docker run --rm --pid host -ti tehbilly/htop
```
Создадим правило firewall для доступа к порту 9292 VM
```sh
$ gcloud compute firewall-rules create reddit-app \
    --allow tcp:9292 \
    --target-tags=docker-machine \
    --description="Allow PUMA connections" \
    --direction=INGRESS
```
#### Работа с Docker-hub
Авторизация на docker-hub
```sh
$ docker login
```
Заливка образа на docker-hub
```sh
$ docker tag reddit:latest boygruv/otus-reddit:1.0
$ docker push boygruv/otus-reddit:1.0
```
Запуск нашего образа на GCP
```sh
$ docker run --name reddit -d -p 9292:9292 boygruv/otus-reddit:1.0
```
Команды
```sh
$ docker logs reddit -f
$ docker exec -it reddit bash
$ docker start reddit
$ docker stop reddit && docker rm reddit
$ docker run --name reddit --rm -it boygruv/otus-reddit:1.0 bash
$ docker inspect boygruv/otus-reddit:1.0
$ docker inspect boygruv/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
$ docker run --name reddit -d -p 9292:9292 boygruv/otus-reddit:1.0
$ docker exec -it reddit bash
$ docker diff reddit
$ docker stop reddit && docker rm reddit 
$ docker run --name reddit --rm -it boygruv/otus-reddit:1.0 bash
```
Интеграция с slack.room
```sh
$ travis encrypt "devops-team-otus:<token>#aleksey_ermolaev" --add notifications.slack.rooms --com
```

******************

## Homework-12
#### Работа с Docker
Установка docker
```sh
$ sudo apt-get update
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce
$ sudo docker version
```
Комманды
```sh
## Список запущенных контейнеров
$ sudo docker ps
## Список всех контейнеров
$ sudo docker ps -a
## Список сохранненных образов
$ sudo docker images
## Запустить контейнер и подключиться к нему
$ docker run -it ubuntu:16.04 /bin/bash
## Запустить новый процесс в нутри контейнера
$ docker exec -it <u_container_id> bash
## Создать image из контейнера
$ docker commit <u_container_id> yourname/ubuntu-tmp-file
```
> Docker run каждый раз запускает новый контейнер

> Если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске

Просмотр списка контейнеров
```sh
$ sudo docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
```
- **docker start** - запускает остановленный (уже созданный) контейнер
- **docker attach** - подсоединяет терминал к созданному контейнеру

Параметры запуска контейнера
- -i – запускает контейнер в foreground режиме (docker attach)
- -d – запускает контейнер в background режиме
- -t создает TTY

```sh
## Удалить запущенные контейнеры
$ docker kill $(docker ps -q)
## Посмотреть сколько дискового пространства заниют образа
$ docker system df
## Удалить контейнер
$ docker rm <container_id>
$ docker rm -f <container_id>
## Удалить образ
$ docker rmi <image_id>
## Удалить все незапущенные контейнеры
$ docker rm $(docker ps -a -q)
## Удалить все образа
$ docker rmi $(docker images -q) 
```
