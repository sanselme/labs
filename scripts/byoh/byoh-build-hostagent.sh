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

: "${BYOH_VERSION:="v0.4.0"}"

[[ ${ARCH} == "aarch64" ]] && ARCH="arm64"

tempdir=$(mktemp -d)
dst="${1:-"/usr/local/bin"}/byoh-hostagent"

# clone repo
git clone --branch "${BYOH_VERSION}" --depth 1 https://github.com/vmware-tanzu/cluster-api-provider-bringyourownhost "${tempdir}"
cd "${tempdir}" || exit

# patch Makefile
sed -i '' "s/amd64/${ARCH}/g" ./Makefile

# build
make host-agent-binaries

# install
sudo cp -f "./bin/byoh-hostagent-linux-${ARCH}" "${dst}"
sudo chmod +x "${dst}"

# cleanup
cd - || exit
rm -rf "${tempdir}"
