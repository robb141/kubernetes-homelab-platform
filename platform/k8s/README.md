# Kubernetes (local) — Docker Desktop

Context: `kubectl config use-context docker-desktop`

## 1. Build images (same Docker engine as Kubernetes)

```bash
docker build -t homelab-api:0.1.0 apps/backend
docker build -t homelab-frontend:0.1.0 apps/frontend
```

## 2. Deploy backend + frontend

```bash
kubectl apply -f platform/k8s/backend/
kubectl apply -f platform/k8s/frontend/

kubectl -n homelab get pods,svc
kubectl -n homelab wait --for=condition=ready pod -l app=backend --timeout=60s
kubectl -n homelab wait --for=condition=ready pod -l app=frontend --timeout=60s
```

Debug API only (port-forward):

```bash
kubectl -n homelab port-forward svc/backend 8000:8000
```

## 3. Install Ingress controller (one-time per cluster)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml

kubectl -n ingress-nginx wait --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=120s
```

## 4. Apply Ingress + local DNS

```bash
kubectl apply -f platform/k8s/ingress.yaml
```

Add to `/etc/hosts` (macOS/Linux):

```text
127.0.0.1 homelab.local
```

Open: http://homelab.local

## 5. Remove app resources

```bash
kubectl delete -f platform/k8s/ingress.yaml
kubectl delete -f platform/k8s/frontend/
kubectl delete -f platform/k8s/backend/
```
