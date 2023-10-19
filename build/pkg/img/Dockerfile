ARG BASE_IMAGE=ubuntu:22.04

# trunk-ignore(terrascan/AC_DOCKER_0041)
FROM ${BASE_IMAGE}

ARG COSIGN_VERSION=2.0.0
ARG CRICTL_VERSION=1.26.0
ARG NOTARY_VERSION=0.6.1
ARG SOPS_VERSION=3.7.3
ARG VAULT_VERSION=1.13.1
ARG YQ_VERSION=4.6.0

ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV DEBIAN_FRONTEND=noninteractive

COPY . /src

# trunk-ignore(terrascan/AC_DOCKER_0002)
RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  dbus \
  git \
  gnupg \
  jq \
  libsystemd0 \
  patch \
  python3-openstackclient \
  python3-heatclient \
  python3-pip \
  socat \
  software-properties-common \
  sudo \
  systemd \
  systemd-sysv \
  udev \
  unzip \
  util-linux \
  vim \
  zip \
  # Prevents journald from reading kernel messages from /dev/kmsg
  && echo "ReadKMsg=no" >> /etc/systemd/journald.conf \
  # Don't start any optional services except for the few we need.
  # (specifically, don't start avahi-daemon, isc-dhcp-server, or libvirtd)
  && find /etc/systemd/system \
  /lib/systemd/system \
  -path '*.wants/*' \
  -not -name '*journald*' \
  -not -name '*systemd-tmpfiles*' \
  -not -name '*systemd-user-sessions*' \
  -exec rm \{} \; \
  && systemctl set-default multi-user.target

# TODO: Verify checksums
RUN curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_$(dpkg --print-architecture).tar.gz" \
  | tar xz && mv "yq_linux_$(dpkg --print-architecture)" /usr/local/bin/yq

# TODO: Install vault

# TODO: Install MAAS

# TODO: Configure MAAS with tls

# TODO: Configure MAAS with vault

# Housekeeping
# trunk-ignore(terrascan/AC_DOCKER_0002)
RUN apt-get clean -y \
  && rm -rf \
  /var/cache/debconf/* \
  /var/lib/apt/lists/* \
  /var/log/* \
  /tmp/*     \
  /var/tmp/* \
  /usr/share/doc/* \
  /usr/share/man/* \
  /usr/share/local/*

# quiet sudo for the admin user
RUN umask 0337; echo 'Defaults:admin !pam_session, !syslog' > /etc/sudoers.d/99-admin-no-log

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

EXPOSE 80 443 6443

# Initalize systemd
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=console 3>&1"]
