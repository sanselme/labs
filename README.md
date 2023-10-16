# Readme

[![OpenSSF Best Practices][ossf-best-practice-badge]][ossf-best-practice-link]
[![OpenSSF Scorecard][ossf-score-badge]][ossf-score-link]
[![Contiuos Integration][ci-badge]][ci-link]
[![Review][review-badge]][review-link]
[![Releases][releases-badge]][releases-link]

[ossf-best-practice-badge]: https://www.bestpractices.dev/projects/7948/badge
[ossf-best-practice-link]: https://www.bestpractices.dev/projects/7948
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

- [cilium](https://cilium.io/)
- [docker](https://docs.docker.com/get-docker/)
- [helm](https://helm.sh/docs/intro/install/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kustomize](https://kustomize.io/)

Create environment variables

```bash
cp -f .env.example .env
```

Configure environment variables and run demo

```bash
./tools/run-demo.sh
```

### sandbox cluster

```bash
./tools/kind-cluster.sh

# optionally: to include ceph (also uncomment ceph related lines)
./tools/kind-prepare-ceph.sh

# deploy sandbox workload
./tools/sandbox.sh
```

### bootstrap docker (k0smotron)

```bash
./tools/bootstrap-docker.sh
```

### bootstrap kubernetes (k0smotron - single node)

```bash
./tools/bootstrap-kubernetes.sh
```

### bootstrap multipass (capi - 3 nodes)

```bash
./tools/bootstrap-multipass.sh
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
