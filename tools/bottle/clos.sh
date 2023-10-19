#!/bin/bash

# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
set -e

export CLUSTERCTL_VERSION=1.5.2
export COSIGN_VERSION=2.2.0
export KREW_VERSION=0.4.4
export SOPS_VERSION=3.8.1
export YQ_VERSION=4.35.2

OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
KREW="krew-${OS}_${ARCH}"
export OS ARCH KREW

export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_FRONTEND=noninteractive

export PATH="${KREW_ROOT}/bin${PATH:+:${PATH}}"

# Install packages
apt-get update -qq &&
  apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    cephfs-shell \
    curl \
    dbus \
    fdisk \
    gdisk \
    git \
    gnupg \
    ipvsadm \
    jq \
    libcephfs2 \
    libsystemd0 \
    nfs-ganesha \
    nfs-ganesha-ceph \
    parted \
    patch \
    python3-heatclient \
    python3-openstackclient \
    python3-pip \
    software-properties-common \
    sudo \
    systemd \
    systemd-sysv \
    udev \
    unzip \
    util-linux \
    vim \
    zip

# Configure external repositories
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg |
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
  tee /etc/apt/sources.list.d/hashicorp.list &&
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg |
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" |
    tee /etc/apt/sources.list.d/helm-stable-debian.list

# Install packages from external repositories
apt-get update -qq &&
  apt-get install -y --no-install-recommends \
    helm \
    vault &&
  # Prevents journald from reading kernel messages from /dev/kmsg
  echo "ReadKMsg=no" >>/etc/systemd/journald.conf &&
  # Don't start any optional services except for the few we need.
  # (specifically, don't start avahi-daemon, isc-dhcp-server, or libvirtd)
  find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \; &&
  systemctl set-default multi-user.target

# TODO: Verify checksums
# Install binaries
curl -fsSLo /usr/local/bin/clusterctl "https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-linux-$(dpkg --print-architecture)" &&
  chmod +x /usr/local/bin/clusterctl &&
  curl -fsSLo /usr/local/bin/cosign "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-$(dpkg --print-architecture)" &&
  chmod +x /usr/local/bin/cosign &&
  curl -fsSLo /usr/local/bin/sops "https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.$(dpkg --print-architecture)" &&
  chmod +x /usr/local/bin/sops &&
  curl -fsSLO "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_$(dpkg --print-architecture).tar.gz" |
  tar xzf "yq_linux_$(dpkg --print-architecture).tar.gz" -C /usr/local/bin/ && mv /usr/local/bin/yq_linux_arm64 /usr/local/bin/yq &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/${KREW}.tar.gz" |
  tar xzf "${KREW}.tar.gz" -C "/tmp/"

# Install krew plugins
"/tmp/${KREW}" install krew &&
  kubectl krew install \
    ca-cert \
    cert-manager \
    ctx \
    gopass \
    hns \
    images \
    konfig \
    minio \
    node-shell \
    ns \
    oidc-login \
    open-svc \
    openebs \
    operator \
    outdated \
    rabbitmq \
    rook-ceph \
    starboard \
    view-secret \
    view-serviceaccount-kubeconfig \
    view-utilization

# Housekeeping
apt-get clean -y &&
  rm -rf \
    ./*.tar.gz \
    /var/cache/debconf/* \
    /var/lib/apt/lists/* \
    /var/log/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/doc/* \
    /usr/share/man/* \
    /usr/share/local/*

# quiet sudo for the admin user
umask 0337
echo 'Defaults:admin !pam_session, !syslog' >/etc/sudoers.d/99-admin-no-log
