export SHELL := bash
version:=0.1.0


MINIKUBE_VERSION := v1.25.2
KUBECTL_VERSION := v1.23.5
HELM_VERSION := v3.8.1

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