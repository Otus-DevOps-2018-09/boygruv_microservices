FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y curl sudo

RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.20.0/minikube-linux-amd64 && chmod +x minikube && mv m
inikube /usr/local/bin/

RUN minikube start --vm-driver=none
COPY autoheal /usr/local/bin/autoheal
RUN chmod 0777 /usr/local/bin/autoheal

EXPOSE 9099

ENTRYPOINT ["/usr/local/bin/autoheal"]
CMD [ "server --config-file=/etc/autohead.yml --logtostderr" ]
