all: push

VERSION = v0.6
BUILD_DATE = $(shell date +"%Y-%m-%d")

TAG = $(VERSION)-$(BUILD_DATE)
PREFIX = quay.io/widen/fluentd-k8s-cloudwatch-logs

build:
	docker build --pull -t $(PREFIX):$(TAG) .

tag: build
	docker tag -f $(PREFIX):$(TAG) $(PREFIX):$(VERSION)

push: tag
	docker push $(PREFIX):$(TAG)
	docker push $(PREFIX):$(VERSION)

clean:
	docker rmi -f $(PREFIX):$(TAG)
	docker rmi -f $(PREFIX):$(VERSION)
