# Helm — homelab chart

Packages backend, frontend, and Ingress into one installable unit.

## Preview rendered YAML (no cluster changes)

```bash
helm template homelab platform/helm/homelab
```

## Install / upgrade

Always pass the environment namespace so the release lives alongside the app.
Do not install into `default` (that causes namespace ownership errors).

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace platform-dev \
  -f platform/helm/homelab/values.yaml \
  -f platform/helm/homelab/values-dev.yaml
```

If you previously installed into `default`, uninstall first:

```bash
helm uninstall homelab -n default
# then install into a Terraform-managed environment namespace
```

## Environment value files

**Dev** (local images from `values.yaml`, dev hostname + env):

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace platform-dev \
  -f platform/helm/homelab/values.yaml \
  -f platform/helm/homelab/values-dev.yaml
```

Add to `/etc/hosts`: `127.0.0.1 homelab-dev.local`

**Staging** (separate namespace, hostname, and backend environment):

```bash
helm upgrade --install homelab platform/helm/homelab \
  --namespace platform-staging \
  -f platform/helm/homelab/values.yaml \
  -f platform/helm/homelab/values-staging.yaml
```

Terraform creates both namespaces and their resource policies. Helm and ArgoCD
deploy workloads into them; they do not own namespace lifecycle.

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
  --namespace platform-dev \
  -f platform/helm/homelab/values-dev.yaml \
  --set backend.environment=experiment
```

## Uninstall

```bash
helm uninstall homelab --namespace platform-dev
```
