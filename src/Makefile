USER_NAME = boygruv

# Сборка ВСЕХ докер образаов
.PHONY: all
all: ui comment post prometheus alertmanager

# Сборка докер образа prometheus
.PHONY: prometheus
prometheus: 
	cd ../monitoring/prometheus/ ; docker build -t $(USER_NAME)/prometheus .

# Сборка докер образа alertmanager
.PHONY: alertmanager
alertmanager: 
	cd ../monitoring/alertmanager/ ; docker build -t $(USER_NAME)/alertmanager .

# Сборка докер образа ui
.PHONY: ui
ui: 
	export USER_NAME=$(USER_NAME) ; cd ui/ ; ./docker_build.sh

# Сборка докер образа comment
.PHONY: comment
comment: 
	export USER_NAME=$(USER_NAME) ; cd comment/ ; ./docker_build.sh

# Сборка докер образа post
.PHONY: post
post: 
	export USER_NAME=$(USER_NAME) ; cd post-py/ ; ./docker_build.sh

# Заливка образов на hub.docker.com
.PHONY: push
push: 
	cat ~/.ssh/dockerhub_password.txt | docker login --username $(USER_NAME) --password-stdin
	docker push $(USER_NAME)/prometheus
	docker push $(USER_NAME)/alertmanager
	docker push $(USER_NAME)/ui
	docker push $(USER_NAME)/comment
	docker push $(USER_NAME)/post
