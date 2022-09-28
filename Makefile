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
export IMAGE = $(REGISTRY)/$(REPOSITORY)/hello-world-kubernetes

MAKECMD= /usr/bin/make --no-print-directory
CURRENT_GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

all: ##               old style build and test 
	build test

brun: ##               builds and runs the new binary
	@$(MAKECMD) build
	@$(MAKECMD) run

build: ##               old style build
	docker build \
		--tag $(IMAGE):$(DOCKER_IMAGE_TAG) \
		./

run: ##               run the container
	docker run --name $(DOCKER_IMAGE_NAME) -i -t  -p 3000:3000 $(IMAGE):$(DOCKER_IMAGE_TAG);

shell: ##               run in shell container
	docker exec -it $(DOCKER_IMAGE_NAME) bash

clean: ##               cleans
	docker rm server
	# docker system prune -af --volumes

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

helm_list_endpoints: ##      lists kubernetes endpoints
	kubectl get endpoints -A

helm_list_pods: ##           lists kubernetes pods
	kubectl get pods

helm_del: ##               deletes chart
	helm del $$(helm ls --all --short)

kubectl_deploy: ##           deploy our app
	kubectl expose deployment hello-world-kubernetes-chart-hwk --type=LoadBalancer --name=my-hwk-service

kubectl_list: ##             list our app
	kubectl get services my-hwk-service

kubectl_clean: ##            clean our app deployment
	kubectl delete services my-hwk-service \
	kubectl delete deployment hello-world-kubernetes-chart-hw