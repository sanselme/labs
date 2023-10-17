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

MAAS="hack/maas/charts/maas"

# clone repos
[[ ! -d hack/osh ]] &&
  git clone https://review.opendev.org/openstack/openstack-helm-infra.git hack/osh

[[ ! -d hack/maas ]] &&
  git clone https://review.opendev.org/airship/maas.git hack/maas

# package helm-toolkit
helm package hack/osh/helm-toolkit -d hack/

# update dependencies
HTK="$(find hack -name "helm-toolkit-*.tgz")"
[[ ! -f "hack/maas/charts/deps/$(basename "${HTK}")" ]] &&
  mkdir -p "${MAAS}/charts"
cp -f "${HTK}" "${MAAS}/charts/"

# package maas
helm package "${MAAS}" -d hack/
