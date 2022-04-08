version:=0.1.0

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
