# Kubernetes Homelab Platform

A hands-on learning project: build a **production-style GitOps platform** step by step.

**Current phase:** Phase 4 — ArgoCD GitOps  
**Completed so far:** FastAPI, frontend, Docker, Docker Compose, Kubernetes, Helm, CI  
**Next phases:** CI/CD promotion flow → TLS → Monitoring → Terraform

---

## Architecture

```text
┌──────────────────────────────────────────────────────────────────┐
│ Host (your laptop)                                               │
│                                                                  │
│  Browser ──► http://localhost:8080                               │
│                    │                                             │
│                    ▼                                             │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Docker Compose network / Kubernetes cluster network        │  │
│  │                                                            │  │
│  │  ┌─────────────────┐         ┌─────────────────────────┐   │  │
│  │  │ frontend        │ proxy   │ backend                 │   │  │
│  │  │ Nginx :80       │────────►│ FastAPI + Uvicorn :8000 │   │  │
│  │  │ (static UI)     │ /health │                         │   │  │
│  │  │                 │ /api/*  │ GET /health             │   │  │
│  │  └─────────────────┘         │ GET /api/info           │   │  │
│  │                              └─────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Optional debug: curl http://localhost:8000/health (Compose)     │
└──────────────────────────────────────────────────────────────────┘
```

### Request flow

1. Browser loads UI from Nginx.
2. JavaScript calls `/health` and `/api/info` (same origin — no CORS).
3. Nginx proxies those paths to `http://backend:8000` (service name/DNS).
4. FastAPI returns JSON; Nginx forwards it to the browser.

## GitOps Architecture

```text
GitHub repository
  │
  │ ArgoCD watches platform/helm/homelab on main
  ▼
ArgoCD Application: homelab-dev
  │
  │ renders Helm chart with values.yaml + values-dev.yaml
  ▼
Kubernetes namespace: platform-dev
  │
  ├── backend Deployment + Service
  ├── frontend Deployment + Service
  └── Ingress: homelab-dev.local
```

---

## Repository layout

```text
kubernetes-homelab-platform/
├── apps/
│   ├── backend/          # FastAPI API service
│   └── frontend/         # Static UI + Nginx reverse proxy
├── platform/
│   ├── argocd/           # ArgoCD Application manifests
│   ├── docker-compose/   # Local multi-container stack
│   ├── helm/             # Helm chart and environment values
│   └── k8s/              # Raw Kubernetes manifests from earlier lessons
├── infra/                # Terraform (future)
├── docs/                 # Architecture notes (future)
└── .github/workflows/    # GitHub Actions CI
```

---

## Prerequisites

- Docker Desktop (or Docker Engine + Compose plugin)
- Python 3.12+ (optional — for local dev without Docker)
- Git

---

## Quick start — Docker Compose

```bash
cd platform/docker-compose
docker compose up --build
```

| URL | Purpose |
|-----|---------|
| http://localhost:8080 | Frontend UI (proxied API calls) |
| http://localhost:8000/health | Backend direct (debug) |
| http://localhost:8000/docs | FastAPI OpenAPI docs |

Stop the stack:

```bash
# Ctrl+C in the compose terminal, then:
docker compose down
```

Check health status:

```bash
docker compose ps
# backend should show "healthy" before frontend starts proxying traffic
```

---

## Local dev (backend only, no Docker)

```bash
cd apps/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

---

## Learning roadmap

| Phase | Topics |
|-------|--------|
| 1 | FastAPI, Docker, Docker Compose, K8s, Helm, CI |
| 2 | Kubernetes basics, Deployments, Services, Ingress |
| 3 | Helm charts, values per environment |
| **4 (now)** | ArgoCD GitOps, sync policies, drift |
| 5 | Terraform infra, dev/prod environments |
| 6 | Prometheus, Grafana, TLS, hardening |

---

## CI (GitHub Actions)

On every push/PR to `main`, GitHub Actions builds backend and frontend Docker images.

- **Pull requests:** build only (validates Dockerfiles).
- **Push to `main`:** build and push to `ghcr.io/robb141/homelab-api` and `homelab-frontend` (tags: git SHA + `latest`).

Make packages public (first time): GitHub → Packages → package → Package settings → Change visibility.

Workflow file: [.github/workflows/ci.yml](.github/workflows/ci.yml)

---

## ArgoCD GitOps

ArgoCD is installed in the `argocd` namespace and deploys the dev app from Git:

```bash
kubectl get application homelab-dev -n argocd
```

Expected local state:

```text
NAME          SYNC STATUS   HEALTH STATUS
homelab-dev   Synced        Progressing
```

`Synced` means the live cluster matches the Helm chart rendered from Git. `Progressing` is expected locally while the Ingress controller service has a pending LoadBalancer address.

The ArgoCD Application manifests are:

```text
platform/argocd/homelab-dev-application.yaml
platform/argocd/homelab-staging-application.yaml
```

Apply or update it with:

```bash
kubectl apply -f platform/argocd/homelab-dev-application.yaml
```

### Open The ArgoCD Admin Page

ArgoCD's web UI runs inside the cluster as the `argocd-server` service. Because it is a `ClusterIP` service, access it from your laptop with port forwarding:

```bash
kubectl port-forward svc/argocd-server -n argocd 8081:443
```

Open:

```text
https://localhost:8081
```

The browser may show a certificate warning. That is normal for local development.

Get the initial admin password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

Login:

```text
Username: admin
Password: value printed by the command above
```

If port `8081` is already in use, forward another local port:

```bash
kubectl port-forward svc/argocd-server -n argocd 8082:443
```

Then open:

```text
https://localhost:8082
```

### Test The App Through Ingress

For local clusters, the ingress controller LoadBalancer may stay `<pending>`. Use port forwarding to test HTTP routing:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

In another terminal:

```bash
curl -H "Host: homelab-dev.local" http://localhost:8080/
curl -H "Host: homelab-dev.local" http://localhost:8080/health
curl -H "Host: homelab-dev.local" http://localhost:8080/api/info
```

Expected API response:

```json
{"service":"homelab-platform-api","version":"0.1.0","environment":"gitops-dev"}
```

---

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Liveness-style check |
| GET | `/api/info` | Service metadata (version, environment) |
