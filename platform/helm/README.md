# Helm — homelab chart

Packages backend, frontend, and Ingress into one installable unit.

## Preview rendered YAML (no cluster changes)

```bash
helm template homelab platform/helm/homelab
```

## Install / upgrade

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace homelab \
  --create-namespace
```

## Override values (example: dev)

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace homelab \
  --set backend.environment=dev \
  --set ingress.host=homelab-dev.local
```

## Uninstall

```bash
helm uninstall homelab --namespace homelab
```
