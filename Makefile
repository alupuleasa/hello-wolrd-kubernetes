.PHONY: help
help: ##               This help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

export DOCKER_IMAGE_NAME ?= server
export DOCKER_IMAGE_TAG ?= v1.0.0
export RED='\033[0;31m'
export NC='\033[0m'
export REGISTRY ?= docker.io
export REPOSITORY ?= alupuleasa
export IMAGE = $(REGISTRY)/$(REPOSITORY)/hello-world

MAKECMD= /usr/bin/make --no-print-directory
CURRENT_GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

# all: ##               old style build and test 
# 	build test

brun: ##               builds and runs the new binary
	@$(MAKECMD) build
	@$(MAKECMD) run

build: ##               builds docker image
	docker build \
		--tag $(IMAGE):$(DOCKER_IMAGE_TAG) \
		./

run: ##               run the container
	docker run --name $(DOCKER_IMAGE_NAME) -i -t  -p 80:80 $(IMAGE):$(DOCKER_IMAGE_TAG);

shell: ##               run in shell container
	docker exec -it $(DOCKER_IMAGE_NAME) bash

# clean: ##               cleans
# 	docker rm server
# 	# docker system prune -af --volumes

stop: ##               stop
	docker container stop $(docker container ls -aq)

login: ##               login on repository
	docker login -u $(REPOSITORY)

deploy: ##               old style deploy
	docker tag $(IMAGE):$(DOCKER_IMAGE_TAG) $(IMAGE):$(DOCKER_IMAGE_TAG); \
	docker push $(IMAGE):$(DOCKER_IMAGE_TAG)

helm_template: ##            generate output base on helm template
	cd ./helm/hello-world-kubernetes && \
	helm template . --values ./values.yaml > output;

helm_install: ##             installs helm template
	cd ./helm/hello-world-kubernetes && \
	helm install chart-hwk . -f values.yaml

helm_del: ##               deletes chart
	helm del $$(helm ls --all --short)

svc_url: ##              get service url
	minikube service hello-world-kubernetes-chart-hwk --url

# helm_list_endpoints: ##      lists kubernetes endpoints
# 	kubectl get endpoints -A

# kubectlt_pods: ##           lists kubernetes pods
# 	kubectl get pods

# kubectl_deploy: ##           deploy our app
# 	kubectl expose deployment hello-world-kubernetes-chart-hwk --port=80 --target-port=80 --type=LoadBalancer --name=my-hwk-service

# kubectl_list: ##             list our app
# 	kubectl get services my-hwk-service && echo "\n" && \
# 	kubectl get svc

# kubectl_clean: ##            clean our app deployment
# 	kubectl delete services my-hwk-service \
# 	kubectl delete deployment hello-world-kubernetes-chart-hwk

# sudo kubectl port-forward pod/hello-world-kubernetes-chart-hwk-575d78d4cd-2mmkl 80:80
# kubectl get service hello-world-kubernetes-chart-hwk --output='jsonpath={.spec.ports[0].nodePort}'
# minikube dashboard

#kubectl expose deployment hello-world-kubernetes-chart-hwk --type=LoadBalancer --name=my-hwk-service


#http://127.0.0.1:43119
#http://192.168.49.2:32209