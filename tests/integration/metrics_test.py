import requests
import json

def test_metrics_endpoint():
    response = requests.get('http://localhost:9095/metrics')
    assert response.status_code == 200


def test_http_get_counter():
    _send_request('https://facebook.com')
    metric_response = requests.get('http://localhost:9095/metrics')
    assert 'http_get_total{code="200",url="https://facebook.com"} 1.0' in metric_response.text

    _send_request('https://facebook.com')
    # Counter should increment to 2.
    metric_response = requests.get('http://localhost:9095/metrics')
    assert 'http_get_total{code="200",url="https://facebook.com"} 2.0' in metric_response.text


def test_multiple_url():
    _send_request('https://github.com')
    _send_request('https://github.com')
    _send_request('https://google.com')

    metric_response = requests.get('http://localhost:9095/metrics')

    # Should expect one count of google.com and two counts of github.com requests
    assert 'http_get_total{code="200",url="https://github.com"} 2.0' in metric_response.text
    assert 'http_get_total{code="200",url="https://google.com"} 1.0' in metric_response.text

def _send_request(url):
    payload = {'url' : url}
    headers = {'content-type' : 'application/json'}
    r = requests.post('http://localhost:8080', data=json.dumps(payload), headers=headers)
    assert r.status_code == 200
