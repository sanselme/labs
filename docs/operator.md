# Operator

## Cloud

```yaml
spec:
  carriers: []Site
  cruisers: []Site
  depot: Site
  harbor: Site
  source: <CodeCloud>
  providers: []Provider
```

## Site

```yaml
spec:
  profile: Profile
  type: [carrier|cruiser|depot|harbor|codecloud]
  packages: []Package
  stacks: []Stack
```

## Profile

```yaml
spec:
  charts: []HelmRelease
  manifests: []Kustomization
  packages: []Package
  stacks: []Stack
```

## Stack

```yaml
spec:
  charts: []HelmRelease
  manifests: []Kustomization
  packages: []Package
```

## Package

```yaml
spec:
  charts: []HelmRelease
  manifests: []Kustomization
```
