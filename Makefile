VENV:=.venv
$(VENV): requirements.txt
	rm -rf $(VENV)
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -r requirements.txt