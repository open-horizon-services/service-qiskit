all: run

# Set these to your own values first
JUPYTER_TOKEN=secr3t
DOCKERHUB_ID=ibmosquito
SERVICE_NAME ?= service-qiskit
SERVICE_VERSION ?= 1.0.0
PATTERN_NAME ?= pattern-service-qiskit

ARCH=$(shell uname -m)
ifeq ($(ARCH), armv7l)
    ARCH=arm32
else ifeq($(ARCH), x86_64)
    ARCH=amd64
else
    ARCH=unknown
endif

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS ?=

default: build run

build: 
	docker build -t $(DOCKERHUB_ID)/qiskit_$(ARCH):1.0.0 -f Dockerfile.$(ARCH) .

dev: build
	-docker rm -f qiskit 2>/dev/null
	docker run -it -e JUPYTER_TOKEN=$(JUPYTER_TOKEN) -p 8888:8888 --name qiskit $(DOCKERHUB_ID)/qiskit_$(ARCH):1.0.0 /bin/bash

run:
	-docker rm -f qiskit 2>/dev/null
	docker run -d -e JUPYTER_TOKEN=$(JUPYTER_TOKEN) -p 8888:8888 --restart unless-stopped --name qiskit $(DOCKERHUB_ID)/qiskit_$(ARCH):1.0.0

test:
	@curl -sS http://127.0.0.1:8888
	
push:
	docker push $(DOCKERHUB_ID)/qiskit_$(ARCH):1.0.0

check:
	@echo "Point your browser to: \"http://localhost:8888/\""

publish-service:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        SERVICE_CONTAINER="$(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)" \
        hzn exchange service publish -O $(CONTAINER_CREDS) -f service.json --pull-image

publish-pattern:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json

stop:
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION) >/dev/null 2>&1 || :

agent-run: agent-stop
	@hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	@hzn unregister -f

.PHONY: build dev run push publish-service publish-pattern test stop clean agent-run agent-stop
