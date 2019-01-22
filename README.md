# boygruv_microservices
## Homework-22
#### Разворачиваем Kubernetes локально
- **kubectl** -главная утилита для работы c Kubernetes API
- Директории ~/.kube - содержит служебную инфу для kubectl (конфиги, кеши, схемы API)
- minikube - утилита для разворачивания локальной инсталляции Kubernetes. 
- Установка kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl/
- Установка Minikube (необходим гипервизор VirtualBox или KVM)
```sh
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.27.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```
- Запуск Minukube-кластера
```sh
$ minikube start
```
> P.S. 
Если нужна конкретная версия kubernetes, указывайте флаг --kubernetes-version <version> (v1.8.0)
По умолчанию используется VirtualBox. Если у вас другой гипервизор, то ставьте флаг --vm-driver=<hypervisor>
- Порядок конфигурирования kubectl
   - Создать cluster: 
   ```
   $ kubectl config set-cluster ... cluster_name
   ```
   - Создать данные пользователя (credentials): 
   ```
   $ kubectl config set-credentials ... user_name
   ```
  - Создать контекст
  ```
  $ kubectl config set-context context_name \
  --cluster=cluster_name \ 
  --user=user_name
  ```
  - Использовать контекст
  ```
  $ kubectl config use-context context_name
  ```
  - Деплой: 
  ```
  $ kubectl apply -f <file_name>.yml
  ```
  - Просмотр
  ```
  $ kubectl get deployment 
  ```
  - Посмотреть Endpoints
  ```
  kubectl describe service comment | grep Endpoints
  ```
  - Запуск команды в нутри пода
  ```
  $ kubectl exec -ti <pod-name> nslookup comment
  ```
  - Пропрос порта из пода на localhost
  ```
  $ kubectl port-forward <pod-name> 9292:9292
  ```
  - Просмотр логов пода
  ```
  kubectl logs post-56bbbf6795-7btnm
  ```
- По-умолчанию все сервисы имеют тип ClusterIP - это значит, что сервис распологается на внутреннем диапазоне IP-адресов кластера. Снаружи до него нет доступа
- Тип NodePort - на каждой ноде кластера открывает порт из диапазона 30000-32767 и переправляет трафик с этого порта на тот, который указан в targetPort Pod (похоже на стандартный expose в docker

#### Namespaces
При старте Kubernetes кластер уже имеет 3 namespace: 
  - **default** - для объектов для которых не определен другой Namespace (в нем мы работали все этовремя) 
  - **kube-system** - для объектов созданных Kubernetes’ом и для управления им
  - **kube-public** - для объектов к которым нужен доступ из любой точки кластера
- Запуск Minikube Dashboard
```
$ minikube service kubernetes-dashboard -n kube-system
```
- Запуск приложения в namespace dev
```
$ kubectl apply -n dev -f ... 
```
#### Google Kubernetes Engine
- Подключение к Kubernetes кластеру GKE
```
$ gcloud container clusters get-credentials cluster-1 --zone 
us-central1-a --project docker-182408
``` 
- Проверить контекст подключения
```
$ kubectl config current-context
```
- Деплой приложения в GKE в namespace dev из каталога ./kubernetes/reddit/
```
$ kubectl apply -f ./kubernetes/reddit/ -n dev
```
- Посмотреть внейний адрес кластера
```
$ kubectl get nodes -o wide
```
- Посмотреть NodePort сервиса
```
$ kubectl describe service ui  -n dev  | grep NodePort 
```
- Подключение к GKE Dashboard http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
- Дать прав ServiceAccount на просмотр кластера (дадим роль `cluster-admin`)
```
$ kubectl create clusterrolebinding kubernetes-dashboard  --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```


## Homevork-21
#### Введение в Kubernetis
- **Deployment** - задачи
   - Создание Replication Controller-а (следит, чтобы число запущенных Pod-ов соответствовало описанному);
   - Ведение истории версий запущенных Pod-ов (для различных стратегий деплоя, для возможностей отката);
   - Описание процесса деплоя (стратегия, параметры стратегий).

- **Kubernetes The Hard Way** (ручное создание кластера Kubernetes в Google Cloud https://github.com/kelseyhightower/kubernetes-the-hard-way)
- Созданные файлы в процессе прохождения Kubernetes The Hard Way в папке kubernetes/the_hard_way
- Задание со *
   - Создал 3 ansible playbooks
   - kube-resources-create.yml (создает все ресурсы: сеть, подсеть, правила firewall, выделенный IP и VM контроллеров и воркеров)
   - kube-dist-controller.yml (провижинет контроллеры)
   - kube-dist-worker.yml (провижинет воркеров)
   - для запуска приложения в созданном Kubernetes кластере: `kubectl apply -f kebernetes/reddit/`


## Homework-20
#### Система централизированного логирования EFK (ElasticSearch - Fluentd - Kibana)
- Docker драйвер fluentd: https://docs.docker.com/config/containers/logging/fluentd/
- Сервис Kibana длоступен на порту 5601
- Для подключения драйвера логирования fluentd к докер контейнеру прописываем в docker-compose.yml
```
...
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
...
```
- Для структурированных логов в формате JSON прописываем в конфиге fluentd.conf
```
...
<filter service.post> 
  @type parser 
  format json
  key_name log 
</filter> 
...
```
- Для НЕ структурированных логов придется разбирать логи при помощи grok-шаблонов (именованных шаблонов регулярных выражений)
```
... 
<filter service.ui>
  @type parser 
  format grok 
  grok_pattern %{RUBY_LOGGER}
  key_name log 
</filter> 

<filter service.ui>
  @type parser
  format grok
  <grok>
    pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  </grok>
  <grok>
    pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{PATH:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IP:addr} \| method= %{WORD:method} \| response_status=%{INT:response_status}
  </grok>
  key_name message
</filter>
...
```
#### Распределенный трейсинг
- Сбор трассировок помогает получить более глубокие знания о том, как определенные запросы выполняются в распределенной системе
- OpenZipkin — это система распределенной трассировки (https://zipkin.io/)
- Для отслеживания время прохождения пакета zipkin добавляет в header служебные данные для полседующего анализа.
#### Задание со *
- В сломанном коде, в файле post_app.py сервиса post была установлена задержка в 3 секунды, что отражалось в span-е прохождения пакетов на сервере Zipkin


## Homework-19
#### Мониторинг docker-контейнеров
- Для мониторинга docker-контейнеров используем cAdvisor (https://github.com/google/cadvisor)
- WebUI cAdvisor доступен по адресу: `http://<ip_address>:8080`
#### Визуализация метрик: Grafana
- WebUI Grafana доступен по адресу: `http://<ip_address>:3000`
- Дашборды для Grafana: `https://grafana.com/dashboards`

#### Алертинг
- Alertmanager - дополнительный компонент для системы мониторинга Prometheus, который отвечает за первичную обработку алертов и дальнейшую отправку оповещений по заданному назначению

- Docker образы микросервисов: https://hub.docker.com/u/boygruv

#### Задание со *
- Добавил встроенный мониторинг docker-engine. Для проброски порта с метриками в нутрь контейнеров настроил работу docker на адрес 172.17.0.1. Конфигурацию прописал в файле: /etc/docker/daemon.json
```sh
{
  "metrics-addr" : "172.17.0.1:9323",
  "experimental" : true
}
```
- Во встроенном в Docker мониторинге добавились метрики с docker-engine (кол-во собранных контейнеров, кол-во запущенных и остановленных контейеров и т.д.)
- Добавил мониторинг docker контейнеров при помощи инструмента Telegraf от InfluxDB. Вывод метрик добавил в отдельный дашборд
- Добавил в алертинг 95 процентиль времени ответа UI в файл: `monitoring/prometheus/alerts.yml`. Документация: `https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/`
- Добавил оповещения о событиях по email в файл: `monitoring/alertmanager/config.yml`. Документация: `https://prometheus.io/docs/prometheus/latest/configuration/configuration/`
- Добавил в Grafana автоматическое добавление источников данных и дашбордов. При выгрузке дашборда для последующей автоматической загрузки необходимо а json файле с дашбордом почистить id дашборда, поставить `"id": null`
- Для мониторинга хоста через GCP Stackdriver на VM необходимо установить Google Monitoring Agent `https://cloud.google.com/monitoring/agent/install-agent` (при помощи Stackdriver можно собирать следующие метрики: CPU, Memory, Disk, Network traffic, TCP Connection, Proccess, так же возможно собирать метрики с MongoDB. Список всех поддерживаемых плагинов: https://cloud.google.com/monitoring/agent/plugins/)
- Добавил проксирование запросов к Prometheus через обратный прокси Trickster (https://github.com/Comcast/trickster)

#### AWX - open source версия Ansible Tower
- https://github.com/ansible/awx
- Установка (https://habr.com/company/pixonic/blog/352184/):
```sh
$ pip install ansible
$ pip install docker-py
$ git clone https://github.com/ansible/awx.git
$ cd awx/installer

## Меняем в inventory параметр postgres_data_dir 
$ ansible-playbook -i inventory install.yml

## После установки на 80 пору запуститься AWX
## login: Admin    pass: password
```
#### Autoheal - проект команды OpenShift для автоматического иcправления проблем по результатам алертов

- https://github.com/openshift/autoheal
- Для сборки требуется GO
```sh
$ git clone https://github.com/openshift/autoheal
$ make
## Бинарник: _output/local/bin/linux/amd64/autoheal
```
- Т.к. autoheal для работы требуется Kubernetes, я собрал докер образ для работы (boygruv/autoheal) c minikube. Конфиг файл autoheal передается через параметры.
- Пример конфига autoheal
```sh
awx:
  address: http://<AWX_IP_ADDRESS>/api

  credentials:
     username: admin      # Логин для AWX
     password: password   # пароль для AWX

  insecure: true

  project: "Otus"         # Проект AWX

  jobStatusCheckInterval: 1m

throttling:
  #Интервал в течении которого будут игнорированы повторные срабатывания
  interval: 1h

rules:

- metadata:
    name: start-job
  labels:
    alertname: ".*Down"   # Шаблон для Alertname
    job: ".*"             # Шаблон для Job
  awxJob:
    template: "Start jobs" # Название запукаемого Template AWX
```
- В AWX Template добавляем template с названием "Start jobs" которое будет запускаться при срабатывании алерта

- В конфигурационный файл Alertmanager добавил ресивера autoheal и прописал route при срабатывании алерта
```sh
receivers:
 ...
- name: autoheal
  webhook_configs:
  - url: http://autoheal:9099/alerts
```


=======

## Homework-18
#### Мониторинг. Prometheus
- Просмотр метрик Prometheus: `http://<ip_address>:9090/graph`
- Пример метрики:
```sh
prometheus_build_info{branch="HEAD",goversion="go1.9.1",instance="localhost:9090", job="prometheus", revision= "3a7c51ab70fc7615cd318204d3aa7c078b7c5b20",version="1.8.1"}  1 
```
- Targets (цели) - представляют собой системы или процессы, за которыми следит Prometheus `http://<ip_address>:9090/tergets`
- Просмотр "сырых" данных метрик: `http://<ip_address>:9090/metrics`

#### Конфиг: prometheus.yml

```sh
---
global:
  scrape_interval: '5s'  ## Частота сбора метрик

scrape_configs:
  - job_name: 'prometheus' ## Джобы
    static_configs:
      - targets:
        - 'localhost:9090' ## Адреса для сбора метрик (endpoints)

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'
```
#### Exporters
- Программа, которая делает метрики доступными для сбора Prometheus
- Дает возможность конвертировать метрики в нужный для Prometheus формат
- Используется когда нельзя поменять код приложения
- Примеры: PostgreSQL, RabbitMQ, Nginx, Node exporter, cAdvisor

#### Задание со *
- Добавлен мониторинг mongodb
- Добавлен blackbox мониторинг сервисов. Проверяется доступность сервисов по ссылке `http://ui:9292/healthcheck`
- Разработан Makefile для автоматизации сборки сервисов и пуша их в docker репозиторий. Файл резместил в `src\Makefile`. Файл позволяет как собирать все проекты сразу, так и каждый по отдельности.

=======

## Homework-17
#### Расширяем Pipeline
- Добавили окружения dev, stage, production
- Добавили возможность ручного запуска джоба
- Добавили условия и ограничения для запуска джоба
- Добавили в pipeline динамическое окружение (для каждой новой ветки будет создоваться отдельное окружение)


****

## Homework-16
#### Gitlab-CI
- Подготовил сервер Gitlab при помощи Terraform и Ansible
- Для формирования docker-compose.yml  использовал template
- Для передачи внешнего IP адреса созданной VM использовал --extra-vars при запуске плейбука
- Для запуска установки Gitlab сервера: `cd gitlab-ci/infra/terraform && terraform apply`

Запуск gitlab-runner контейнера
```sh
    docker run -d --name gitlab-runner --restart always \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest
```

Регистрация runner
```sh
docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://<ip_address>/" \
  --registration-token "<token>" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "my-runner" \
  --tag-list "linux,xenial,ubuntu,docker" \
  --run-untagged \
  --locked="false"
```
#### Задание со *
- Автоматизация создания и регистрации раннеров: добавил ansible плейбук создающий инстанс на GCP инсталлирующий docker-ce + запуск контейнера с gitlab-runner + регистрация раннера на gitlab сервере.

- Канал Slack для мониторинга Gitlab-CI `https://boygruv.slack.com/messages/CEN6BGA2C/`

****
## Homework-15
#### Типы сетей Docker
- **None** - сеть (в контейнере присутствует только loopback-интерфейс. Связи с host-машиной и внешними сетями нет)

- **Host** - сеть (связь толькос с хост машиной)

- **Bridge** - сеть (сеть по умолчанию, есть связь с внешними сетями и хост машиной)

Для просмотра информации по bridge-интерфейсам установим пакет `bridge-utils`

```sh
$ apt install bridge-utils
```
Просомтр виртуальных интерфейсов
```sh
$ ifconfig | grep br
$ brctl show <interface>
```
Правила `iptables`
```sh
$ sudo iptables -nL -t nat
```
Docker-proxy
```sh
$ ps ax | grep docker-proxy
```

#### Docker-compose
Установка
```sh
$ pip install docker-compose
```
Сборка проекта
```sh
$ docker-compose up -d
```
>Переменные окружения для docker-compose.yml задаем в файле `.env`

>Имя проекта задается переменной окружения COMPOSE_PROJECT_NAME

> Переопределение инструкций `docker-compose.yml` файла делается через `docker-compose.override.yml` файл


****
## Homework-14
#### Микросервисы
- Разбили наше приложение на 3 сервиса: post, comment, ui
- Для каждого микросервиса создали свой образ докер
- Корректность Dockerfile проверили через линтер `hadolint <dockerfile>`

#### Оптимизация Dockerfile
Для оптимизации Dockerfile
- Уменьшаем количество слоев, для этого стараемся команду RUN выполнять через мультилайн
- Выполтяем multi-stage для предотвращения помещения в итоговый образ промежуточных файлов
- Оптимизируем кол-во установленных пакетов (стараемся оставлять только необходимые)

#### bridge - сеть
Создали bridge-сеть для контейнеров поскольку в сети по умолчанию не работают сетевые алиасы
```sh
$ docker network create reddit
```

#### VOLUME
Создали volume для хранения данных
```sh
$ docker volume create reddit_db 
```
Подключение volume к контейнеру
```sh
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
```

******************

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
$ travis login --com
$ travis encrypt "devops-team-otus:<token>#aleksey_ermolaev" --add notifications.slack.rooms --com -r Otus-DevOps-2018-09/boygruv_microservices
```
#### Задание со *
- Создал образ packer с установленным docker-ce
```sh
$ packer validate packer/ubuntu16.json
$ packer build packer/ubuntu16.json
```
- Создал шаблон terraform создающий VM на основе созданного образа packer. Кол-во хостов задаем переменной count
```sh
$ cd ./terraform
$ terraform init
$ terraform plan
$ terraform apply
$ terraform destroy
```
- Создал плейбук ansible для запуска на VM докер образа с приложением из удаленного репозитория
```sh
$ cd ansible
$ ansible-playbook playbooks/deploy.yml
```
- Добавил loadBalancer для создаваемых терраформом VM. IP адрес LB вывел через output переменную

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
