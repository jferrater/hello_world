# Scraper Service

## Make Python virtualenv and installing packages
```bash 
make .venv
source .venv/bin/activate
```

## Run test
```bash
make test
```

## Run the application with Docker
```bash
make run
```

## Testing the Endpoints with curl
1. Returns the status code of a given url
```bash
curl --header "Content-Type: application/json" \
        --request POST \
        --data '{"url": "https://google.com"}' \
        localhost:8080
```
2. Get the Prometheus metrics
```bash
curl localhost:9095/metrics
```