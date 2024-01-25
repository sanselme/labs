apiVersion: k0s.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  api:
    sans:
      - kubernetes.${CLUSTER_NAME}.${SITE_NAME}.${DOMAIN_NAME}
  network:
    provider: custom
    podCIDR: ${CLUSTER_POD_CIDR}
    serviceCIDR: ${CLUSTER_SERVICE_CIDR}
  featureGates:
    - name: UserNamespacesSupport
      enabled: true
  extensions:
    helm:
      charts:
        - name: prometheus
          namespace: observability
          chartname: bitnami/kube-prometheus
          version: 8.22.4
          values: |
            alertmanager:
              enabled: false
            blackboxExporter:
              resources:
                limits: {}
                requests: {}
            global:
              storageClass: openebs-hostpath
            operator:
              configReloaderResources: {}
              resources: {}
            prometheus:
              configReloader:
                service:
                  enabled: true
                serviceMonitor:
                  enabled: true
              externalUrl: prometheus.cluster.local
              persistence:
                enabled: true
              resources: {}
        - name: promtail
          namespace: observability
          chartname: grafana/promtail
          version: 6.15.3
          values: |
            config:
              clients:
                - url: http://loki-gateway/loki/api/v1/push
              enableTracing: true
              enabled: true
              snippets:
                addScrapeJobLabel: true
            configmap:
              enabled: true
            serviceMonitor:
              enabled: true
            sidecar:
              configReloader:
                enabled: true
                serviceMonitor:
                  enabled: true
        - name: cert-manager
          namespace: cert-manager
          chartname: jetstack/cert-manager
          version: v1.13.2
          values: |
            ingressShim:
              defaultIssuerKind: ClusterIssuer
              defaultIssuerName: self-signed-ca-issuer
            installCRDs: true
            podDnsConfig:
              nameservers:
                - 1.1.1.1
                - 9.9.9.9
            podDnsPolicy: None
            prometheus:
              enabled: true
              servicemonitor:
                enabled: true
        - name: cilium
          namespace: kube-system
          chartname: cilium/cilium
          version: 1.14.3
          values: |
            externalIPs:
              enabled: true
            hostFirewall:
              enabled: true
            loadBalancer:
              algorithm: maglev
              l7:
                backend: envoy
              mode: dsr
              serviceTopology: true
            monitor:
              enabled: true
            operator:
              replicas: 1
              prometheus:
                enabled: true
                serviceMonitor:
                  enabled: true
            prometheus:
              enabled: true
              serviceMonitor:
                enabled: true
                trustCRDsExist: true
            proxy:
              prometheus:
                enabled: true
            tunnel: disabled
        - name: openebs
          namespace: kube-system
          chartname: openebs/openebs
          version: 3.9.0
          values: |
            analytics:
              enabled: false
            localprovisioner:
              deviceClass:
                enabled: false
              hostpathClass:
                isDefaultClass: true
            ndm:
              enabled: false
        - name: flux
          namespace: cicd
          chartname: bitnami/flux
          version: 1.1.1
          values: |
            global:
              storageClass: openebs-hostpath
              persistence:
                enabled: true
      repositories:
        - name: bitnami
          url: https://charts.bitnami.com/bitnami/
        - name: grafana
          url: https://grafana.github.io/helm-charts/
        - name: jetstack
          url: https://charts.jetstack.io/
        - name: cilium
          url: https://helm.cilium.io/
        - name: openebs
          url: https://openebs.github.io/charts/
  telemetry:
      enabled: false
