FROM quay.io/widen/debian-slim:8

ENV DEBIAN_FRONTEND noninteractive
ENV BUILD_DEPS "curl ca-certificates make g++"

# ulimit: Ensures there are enough file descriptors for running Fluentd
# sed: Changes the default user and group to root. Allows access to /var/log/docker/... files
RUN apt-get update && \
  apt-get -y --no-install-recommends install ${BUILD_DEPS} sudo && \
  curl -L https://toolbelt.treasuredata.com/sh/install-debian-jessie-td-agent2.sh | sh && \
  sed -i -e "s/USER=td-agent/USER=root/" -e "s/GROUP=td-agent/GROUP=root/" /etc/init.d/td-agent && \
  td-agent-gem install --no-document fluent-plugin-kubernetes_metadata_filter \
    fluent-plugin-cloudwatch-logs fluent-plugin-systemd && \
  ulimit -n 65536  && \
  apt-get -y --purge remove ${BUILD_DEPS} gcc cpp libffi6 libgmp10 && \
  apt-get -y --purge autoremove && apt-get -y clean && \
  rm -rf \
    /usr/share/doc /usr/share/man /usr/share/info /usr/share/locale \
    /var/lib/apt/lists/* /var/log/* /var/cache/debconf/* /tmp/* /var/tmp/*

ENTRYPOINT [ "td-agent" ]
