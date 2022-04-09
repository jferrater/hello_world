import json
import os
import random
import threading
import time

import requests

urls = (
    'https://google.com',
    'https://phaidra.ai',
    'https://github.com',
    'https://tradingview.com',
    'https://facebook.com'
)

SCRAPER_SERVICE = os.environ.get('SCRAPER_SERVICE', 'http://localhost:8080')

def run():
    while True:
        try:
            url = random.choice(urls)
            payload = {'url' : url}
            headers = {'content-type' : 'application/json'}
            requests.post(SCRAPER_SERVICE, data=json.dumps(payload), headers=headers)
        except requests.RequestException:
            print('Scraper Service is not yet available')
            time.sleep(5)

if __name__ == '__main__':
    for _ in range(2):
        thread = threading.Thread(target=run)
        thread.daemon = True
        thread.start()

    while True:
        time.sleep(5)
