all: push

VERSION = v0.9.4
CLOUDWATCH_LOGS_PLUGIN_VERSION = 0.3.3
FLATTEN_HASH_PLUGIN_VERSION = 0.4.0
KUBERNETES_PLUGIN_VERSION = 0.25.3
SYSTEMD_PLUGIN_VERSION = 0.0.4

BUILD_DATE = $(shell date +"%Y-%m-%d")

TAG = $(VERSION)_$(BUILD_DATE)
PREFIX = quay.io/widen/fluentd-k8s-cloudwatch-logs

build:
	docker build --pull \
		--build-arg CLOUDWATCH_LOGS_PLUGIN_VERSION=$(CLOUDWATCH_LOGS_PLUGIN_VERSION) \
		--build-arg FLATTEN_HASH_PLUGIN_VERSION=$(FLATTEN_HASH_PLUGIN_VERSION) \
		--build-arg KUBERNETES_PLUGIN_VERSION=$(KUBERNETES_PLUGIN_VERSION) \
		--build-arg SYSTEMD_PLUGIN_VERSION=$(SYSTEMD_PLUGIN_VERSION) \
		-t $(PREFIX):$(TAG) .

tag: build
	docker tag $(PREFIX):$(TAG) $(PREFIX):$(VERSION)

push: tag
	docker push $(PREFIX):$(TAG)
	docker push $(PREFIX):$(VERSION)

clean:
	docker rmi -f $(PREFIX):$(TAG) || true
	docker rmi -f $(PREFIX):$(VERSION) || true
