import requests
from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route('/', methods=['POST'])
def url_status():
    data = request.json
    url = data['url']

    try:
        r = requests.get(url)
        code = r.status_code
    except requests.exceptions.HTTPError as error:
        print(f'Error: {error}')
        code = 500
    
    return jsonify({'url': url, 'code': code})