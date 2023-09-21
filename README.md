# Readme

[![OpenSSF Scorecard][ossf-score-badge]][ossf-score-link]
[![Contiuos Integration][ci-badge]][ci-link]
[![Review][review-badge]][review-link]
[![Releases][releases-badge]][releases-link]

[ossf-score-badge]: https://api.securityscorecards.dev/projects/github.com/sanselme/labs/badge
[ossf-score-link]: https://securityscorecards.dev/viewer/?uri=github.com/sanselme/labs
[ci-badge]: https://github.com/sanselme/labs/actions/workflows/cicd.yml/badge.svg
[ci-link]: https://github.com/sanselme/labs/actions/workflows/cicd.yml
[review-badge]: https://github.com/sanselme/labs/actions/workflows/review.yml/badge.svg
[review-link]: https://github.com/sanselme/labs/actions/workflows/review.yml
[releases-badge]: https://github.com/sanselme/labs/actions/workflows/release.yml/badge.svg
[releases-link]: https://github.com/sanselme/labs/actions/workflows/release.yml

---
## Usage

Install packages:

- [docker](https://docs.docker.com/get-docker/)
- [flux](https://fluxcd.io/docs/installation/)
- [helm](https://helm.sh/docs/intro/install/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kustomize](https://kustomize.io/)

Create a Kubernetes cluster

[Install flux](#install), generate and apply manifests:

```bash
kustomize build "./deployment/site/${CLUSTER_NAME}/secrets" \
| tee /tmp/secrets.yaml \
| kubectl apply -f -

# Optionaly, install cilium:
kustomize build "./deployment/site/${CLUSTER_NAME}/cni" \
| tee /tmp/cni.yaml \
| kubectl apply -f -

# Optionaly, install rook-ceph:
kustomize build "./deployment/site/${CLUSTER_NAME}/csi" \
| tee /tmp/csi.yaml \
| kubectl apply -f -

kustomize build "./deployment/site/${CLUSTER_NAME}" \
| tee /tmp/site.yaml \
| kubectl apply -f -
```

### Install

```bash
flux install --namespace=flux-system --components-extra="${FLUX_EXTRA_COMPONENTS}"
```

---

Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
