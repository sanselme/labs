---
apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  hosts:
    - role: controller+worker
      noTaints: true
      ssh:
        address: ${K0S_IPADDR}
        keyPath: ${SSH_PUB_KEY_FILE}
        port: 22
        user: ${K0S_USERNAME}
  k0s:
    config:
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: Cluster
      metadata:
        name: ${CLUSTER_NAME}
