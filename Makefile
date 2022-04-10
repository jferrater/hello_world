export SHELL := bash
version := 0.1.0
uname := $(shell uname | tr "[:upper:]" "[:lower:]")

arch := $(shell uname -m)
ifeq ($(arch), arm64)
	arch = arm64
else
	arch = amd64
endif

MINIKUBE_VERSION := v1.25.2
KUBECTL_VERSION := v1.23.5
HELM_VERSION := v3.8.1

TOOLS := kubernetes/bin
$(TOOLS):
	mkdir -p $(TOOLS)

MINIKUBE := $(TOOLS)/minikube
$(MINIKUBE): $(TOOLS)
	rm -rf $(MINIKUBE)
	curl -L -o $(MINIKUBE) https://storage.googleapis.com/minikube/releases/$(MINIKUBE_VERSION)/minikube-$(uname)-$(arch)
	chmod +x $(MINIKUBE)

KUBECTL := $(TOOLS)/kubectl
$(KUBECTL): $(TOOLS)
	rm -rf $(KUBECTL)
	curl -L -o $(KUBECTL) https://storage.googleapis.com/kubernetes-release/release/$(KUBECTL_VERSION)/bin/$(uname)/$(arch)/kubectl
	chmod +x $(KUBECTL)

.PHONY: tools
tools: $(KUBECTL) $(MINIKUBE) 

export PATH := $(shell pwd)/$(TOOLS):$(PATH)
export MINIKUBE_HOME := $(shell pwd)/kubernetes/minikube_home
$(MINIKUBE_HOME):
	mkdir -p $(MINIKUBE_HOME)

export MINIKUBE_PROFILE := minikube-helloworld

export KUBECONFIG := $(shell pwd)/kubernetes/minikube_home/kubeconfig.yaml

.PHONY: local-cluster
local-cluster: tools | $(MINIKUBE_HOME)
	minikube delete || true
	minikube start --embed-certs --driver=docker

# To use this target, run: source <(make k8s-environment)
.PHONY: k8s-environment
k8s-environment:
	@echo "export PATH=$(PATH)"
	@echo "export MINIKUBE_HOME=$(MINIKUBE_HOME)"
	@echo "export KUBECONFIG=$(KUBECONFIG)"
	@echo "export MINIKUBE_PROFILE=$(MINIKUBE_PROFILE)"

.PHONY: delete-cluster
delete-cluster:
	minikube delete || true

VENV:=.venv
$(VENV): requirements.txt
	rm -rf $(VENV)
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -r requirements.txt

.PHONY: test
test:
	python -m pytest tests/app_test.py

.PHONY: build
build:
	docker build -t scraper-service:$(version) .

.PHONY: run
run: build
	docker run -dit -p 8080:8080 -p 9095:9095 --name scraper-service scraper-service:$(version)

.PHONY: integration-test
integration-test: run
	while ! echo exit | nc localhost 9095; do sleep 5; done && \
	docker exec -it scraper-service pytest tests/integration/metrics_test.py
	make docker-rm
	
.PHONY: docker-rm
docker-rm:
	docker stop scraper-service
	docker rm scraper-service

.PHONY: generate-metrics
generate-metrics:
	python request_generator/request_generator.py