Scraper Service
===============
The Scraper Service is a web service that grabs the HTTP GET code of a given URL and exposes a Prometheus metric.

Overview
--------
The project contains a `Makefile` that will automate the development and deployment of the Scraper Service to a local Kubernetes cluster using Minikube

### Making Python virtualenv and installing packages
```bash 
make .venv
source .venv/bin/activate
```

### Running tests
```bash
make test
make integration-test
```

### Running the application with Docker
```bash
make run
```

### Testing the Endpoints with curl
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


Generating metrics
------------------
A python script is created to regularly request to the Scraper Service. This will populate the `http_get` metric with data. The script is in the `request_generator` folder. To run the script:
```bash
make generate-metrics
```

Docker-compose
--------------
There is a docker-compose file that can be used to automatically run the Scraper Service together with Prometheus Server and the metrics generator script.
```bash
docker-compose up -d
```
### Scraper Service PromQL Queries
The Prometheus server would be available at `http://localhost:9090`. The following PromQL query can be used to get the HTTP GET status code of a given url:
- `http_get_total` - get all `http_get` metric. There should be five urls with `http_get` counter metrics generated from the metrics generator.
- `http_get_total{url="https://facebook.com"}` - Get the http_get counter metrics of facebook url.
- `http_get_total{url="https://phaidra.ai"}` - Get the http_get counter metrics of phaidra url.
- `http_get_total{url="https://google.com"}` - Get the http_get counter metrics of google url.
- `http_get_total{url="https://github.com"}` - Get the http_get counter metrics of github url.
- `http_get_total{url="https://tradingview.com"}` - Get the http_get counter metrics of tradingview url.
- `http_get_total{url="https://facebook.com", code="200"}` - Get the counter metrics of facebook url with status code of 200

When you are done, run:
```bash
docker-compose down
```

Local Kubernetes Cluster
------------------------
Deploying a local Kubernetes cluster can be done in a single Makefile target:
```bash
make local-cluster
```
It starts a local K8s cluster. It also downloads the tools: `kubectl` and `minikube` into `kubernetes/bin` directory. In order to use these tools in your current shell, run the command:
```bash
source <(make k8s-environment)
```
Now you have the tools on your `$PATH`. To verify, get the available node of the cluster:
```bash
kubectl get nodes
```
You should see the `minikube-helloworld` node in the cluster:
```bash
NAME                  STATUS   ROLES                  AGE     VERSION
minikube-helloworld   Ready    control-plane,master   5m24s   v1.23.3
```

### Deploying the Scraper Service Kubernetes Resources
The Scraper Service K8s resources is in the `kubernetes` directory. To deploy these resources run:
```bash
kubectl apply -f kubernetes
````
To verify:
```bash
kubectl get all
````
Since an Ingress resource for Scraper Service is deployed, this needs to be enabled in `minikube`. Ingress is an addon to `minikube`. To enable this addon:
```bash
minikube addons enable ingress
```
Then run the following command so that the ingress resources would be available at `"127.0.0.1"` (Note: a sudo password is required):
```bash
minikube tunnel
```
You can now access the Scraper Service at `localhost` on port `80`. Test the Scraper Service:
```bash
curl --header "Content-Type: application/json" \
        --request POST \
        --data '{"url": "https://google.com"}' \
        localhost
```
Viewing the metrics:
```bash
curl localhost/metrics
```

### Deleting the Local Kubernetes Cluster
When you are done, run the following command to delete the local cluster and the downloaded files:
```bash
make delete-cluster
```