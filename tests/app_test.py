import json
from app import app


def test_url_status():

    with app.test_client() as client:
        payload = json.dumps({'url':'https://google.com'})
        response = client.post('/', data=payload, content_type='application/json')

        response_body = json.loads(response.get_data(as_text=True))

        assert response.status_code == 200
        assert response_body['url'] == 'https://google.com'
        assert response_body['code'] == 200