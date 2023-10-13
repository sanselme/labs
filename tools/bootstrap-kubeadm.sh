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

: "${AQUA_REPO:=https://aquasecurity.github.io/helm-charts/}"
: "${BITNAMI:=oci://registry-1.docker.io/bitnamicharts}"
: "${CILIUM_REPO:=https://helm.cilium.io/}"
: "${CM_REPO:=https://charts.jetstack.io/}"
: "${OPENEBS_REPO:=https://openebs.github.io/charts/}"

: "${CILIUM_VERSION:=1.14.1}"
: "${CM_VERSION:=v1.12.3}"
: "${FLUX_VERSION:=}"
: "${OPENEBS_VERSION:=}"
: "${PROM_VERSION:=8.18.0}"
: "${TM_VERSION:=v0.6.0}"
: "${TRIVY_VERSION:=0.17.0}"

# Generate cilium config
cat <<EOF >/tmp/cilium.yaml
 l2announcements:
      enabled: true
ingressController:
    enabled: true
exteranlIPs:
    enabled: true
operator:
    replicas: 1
EOF

# Install cilium
helm upgrade cilium \
  --install cilium \
  --namespace kube-system \
  --repo "${CILIUM_REPO}" \
  --value /tmp/cilium.yaml \
  --version "${CILIUM_VERSION}"
sleep 15
kubectl apply -f hack/lbpool.yaml
kubectl apply -f hack/l2announcement.yaml

# Install openebs
helm upgrade openebs \
  --install openebs \
  --namespace kube-system \
  --repo "${OPENEBS_REPO}" \
  --set localprovisioner.hostpathClass.enabled=true,localprovisioner.hostpathClass.isDefaultClass=true \
  --version "${OPENEBS_VERSION}"
kubectl annotate storageclass openebs-hostpath storageclass.kubernetes.io/is-default-class="true"

# Install cert-manager & trust-manager
helm upgrade cert-manager \
  --create-namespace \
  --install cert-manager \
  --namespace cert-manager \
  --repo "${CM_REPO}" \
  --set installCRDs=true \
  --version "${CM_VERSION}"
helm upgrade trust-manager \
  --install cert-manager \
  --namespace trust-manager \
  --repo "${CM_REPO}" \
  --version "${TM_VERSION}"

# Install prometheus
helm upgrade prometheus \
  --create-namespace \
  --install kube-prometheus \
  --namespace observability \
  --repo "${BITNAMI}" \
  --set prometheus.scrapeInterval="",prometheus.evaluationInterval="" \
  --version "${PROM_VERSION}"

# Install trivy-operator
helm upgrade trivy \
  --create-namespace \
  --install trivy-operator \
  --namespace sre \
  --repo "${AQUA_REPO}" \
  --set operator.replicas=1 \
  --version "${TRIVY_VERSION}"

# Install flux
helm upgrade flux \
  --install flux \
  --namespace sre \
  --repo "${BITNAMI}" \
  --version "${FLUX_VERSION}"
