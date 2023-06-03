---
apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: ${CLUSTER_NAME:-k0s}
spec:
  hosts:
    - role: ${K0S_ROLE:-single}
      ssh:
        address: ${K0S_IPADDR}
        keyPath: ${SSH_PUB_KEY_FILE:-hack/multipass/id_ed25519.pub}
        port: 22
        user: ${K0S_USERNAME:-ubuntu}
  k0s:
    dynamicConfig: false
    version: ${K0S_VERSION:-1.26.8-k0s.0}
    config:
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: Cluster
      metadata:
        name: ${CLUSTER_NAME:-k0s}
