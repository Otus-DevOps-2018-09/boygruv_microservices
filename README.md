# boygruv_microservices

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
