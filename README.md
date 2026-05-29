# Kubernetes Homelab Platform

A hands-on learning project: build a **production-style GitOps platform** step by step.

**Current phase:** Phase 1 — containerized app platform (Docker + Docker Compose)  
**Next phases:** Kubernetes → Helm → ArgoCD → Terraform → Monitoring

---

## Architecture (Phase 1)

```text
┌──────────────────────────────────────────────────────────────────┐
│ Host (your laptop)                                               │
│                                                                  │
│  Browser ──► http://localhost:8080                               │
│                    │                                             │
│                    ▼                                             │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Docker Compose network                                     │  │
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
│  Optional debug: curl http://localhost:8000/health (direct API)  │
└──────────────────────────────────────────────────────────────────┘
```

### Request flow

1. Browser loads UI from Nginx (`:8080` on host → `:80` in container).
2. JavaScript calls `/health` and `/api/info` (same origin — no CORS).
3. Nginx proxies those paths to `http://backend:8000` (Compose internal DNS).
4. FastAPI returns JSON; Nginx forwards it to the browser.

---

## Repository layout

```text
kubernetes-homelab-platform/
├── apps/
│   ├── backend/          # FastAPI API service
│   └── frontend/         # Static UI + Nginx reverse proxy
├── platform/
│   └── docker-compose/   # Local multi-container stack
├── infra/                # Terraform (future)
├── docs/                 # Architecture notes (future)
└── .github/workflows/    # CI/CD (future)
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
| **1 (now)** | FastAPI, Docker, Docker Compose, networking |
| 2 | Kubernetes basics, Deployments, Services, Ingress |
| 3 | Helm charts, values per environment |
| 4 | ArgoCD GitOps, sync policies, drift |
| 5 | Terraform infra, dev/prod environments |
| 6 | Prometheus, Grafana, TLS, hardening |

---

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Liveness-style check |
| GET | `/api/info` | Service metadata (version, environment) |
