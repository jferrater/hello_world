import logging
import os

import requests
from flask import Flask, jsonify, request
from prometheus_client import Counter, start_wsgi_server

log = logging.getLogger(__name__)

app = Flask(__name__)
start_wsgi_server(int(os.environ.get('PROMETHEUS_PORT', 9095)))

http_get_metric = Counter('http_get', ' Http GET metric', ['url', 'code'])


@app.route('/', methods=['GET'])
def hello():
    return 'hello'


@app.route('/', methods=['POST'])
def url_status():
    data = request.json
    url = data['url']

    try:
        r = requests.get(url)
        code = r.status_code
    except requests.exceptions.HTTPError as error:
        log.error('An error occurred when requesting to %s: %s', url, error)
        code = 500
    
    http_get_metric.labels(url=url, code=code).inc()

    return jsonify({'url': url, 'code': code})
