FROM quay.io/widen/ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV BUILD_DEPS "curl ca-certificates make g++"

ARG CLOUDWATCH_LOGS_PLUGIN_VERSION
ENV CLOUDWATCH_LOGS_PLUGIN_VERSION ${CLOUDWATCH_LOGS_PLUGIN_VERSION}

ARG KUBERNETES_PLUGIN_VERSION
ENV KUBERNETES_PLUGIN_VERSION ${KUBERNETES_PLUGIN_VERSION}

ARG SYSTEMD_PLUGIN_VERSION
ENV SYSTEMD_PLUGIN_VERSION ${SYSTEMD_PLUGIN_VERSION}

# ulimit: Ensures there are enough file descriptors for running Fluentd
# sed: Changes the default user and group to root. Allows access to /var/log/docker/... files
RUN apt-get update && \
  apt-get -y --no-install-recommends install ${BUILD_DEPS} iproute2 sudo && \
  curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-xenial-td-agent2.sh | sh && \
  sed -i -e "s/USER=td-agent/USER=root/" -e "s/GROUP=td-agent/GROUP=root/" /etc/init.d/td-agent && \
  td-agent-gem install --no-document \
    fluent-plugin-cloudwatch-logs:${CLOUDWATCH_LOGS_PLUGIN_VERSION} \
    fluent-plugin-kubernetes_metadata_filter:${KUBERNETES_PLUGIN_VERSION} \
    fluent-plugin-systemd:${SYSTEMD_PLUGIN_VERSION} && \
  ulimit -n 65536  && \
  apt-get -y --purge remove ${BUILD_DEPS} gcc cpp libffi6 libgmp10 && \
  apt-get -y --purge autoremove && apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* /var/cache/debconf/* /tmp/* /var/tmp/*

ENTRYPOINT ["td-agent"]
