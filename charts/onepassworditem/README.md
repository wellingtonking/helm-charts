# The 1Password _onepassworditem_ chart

Chat to use as a dependency in your own chart to create 1Password items.

## Usage

To use the _onepassworditem_ chart, add it as a dependency in your own chart's `Chart.yaml` file:

```yaml
dependencies:
  - name: onepassworditem
    version: 1.x
    repository: https://wellingtonking.github.io/helm-charts
```

Then for example, in a value file:

```yaml
---
onepassworditem:
  items:
    enabled: true
    items:
      - name: argocd-secret
        itemPath: "vaults/My Vault/items/My ArgoCD Secret Item"

argo-cd:
  controller:
    replicas: 1
  [...]
```

This will create your expected _onepassworditem_ item objects so you dont have
to copy and paste the same _onepassworditem_ template into your own chart all
the time.