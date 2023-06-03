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

PKGS=("cri-tools" "kubernetes-cni" "kubectl" "kubelet" "kubeadm")

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg |
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# add kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] \
  https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# install packages
sudo apt update -y
for pkg in ${PKG[@]}; do
  sudo apt install -y "${pkg}" && sudo apt-mark hold "${pkg}"
done
