---
apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  hosts:
    - role: single
      ssh:
        address: ${K0S_IPADDR}
        keyPath: ${SSH_PUB_KEY_FILE}
        port: 22
        user: ${K0S_USERNAME}
  k0s:
    dynamicConfig: false
    version: 1.26.8-k0s.0
    config:
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: Cluster
      metadata:
        name: ${CLUSTER_NAME}
