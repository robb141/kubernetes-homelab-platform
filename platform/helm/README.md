# Helm — homelab chart

Packages backend, frontend, and Ingress into one installable unit.

## Preview rendered YAML (no cluster changes)

```bash
helm template homelab platform/helm/homelab
```

## Install / upgrade

Always pass **`--namespace homelab`** so the release lives in the same namespace as the app.
Do not install into `default` (that causes namespace ownership errors).

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace homelab \
  --create-namespace
```

If you previously installed into `default`, uninstall first:

```bash
helm uninstall homelab -n default
kubectl delete namespace homelab
# then run upgrade --install with --namespace homelab again
```

## Environment value files

**Dev** (local images from `values.yaml`, dev hostname + env):

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace homelab \
  --create-namespace \
  -f platform/helm/homelab/values.yaml \
  -f platform/helm/homelab/values-dev.yaml
```

Add to `/etc/hosts`: `127.0.0.1 homelab-dev.local`

**Prod** (GHCR images — after CI has pushed them):

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace homelab \
  -f platform/helm/homelab/values.yaml \
  -f platform/helm/homelab/values-prod.yaml
```

Later, ArgoCD will apply these same value files from Git (GitOps).

## One-off overrides

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace homelab \
  --set backend.environment=staging
```

## Uninstall

```bash
helm uninstall homelab --namespace homelab
```
