import os
import time

from fastapi import FastAPI, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, Info, generate_latest

app = FastAPI(
    title="Homelab Platform API",
    version="0.1.1",
    description="Minimal backend for our GitOps learning platform.",
)

REQUEST_COUNT = Counter(
    "homelab_api_http_requests_total",
    "Total HTTP requests handled by the Homelab API.",
    ["method", "path", "status_code"],
)

REQUEST_LATENCY = Histogram(
    "homelab_api_http_request_duration_seconds",
    "HTTP request latency for the Homelab API.",
    ["method", "path"],
)

APP_INFO = Info(
    "homelab_api",
    "Homelab API build and runtime information.",
)
APP_INFO.info(
    {
        "version": app.version,
        "environment": os.getenv("ENVIRONMENT", "local"),
    }
)


@app.middleware("http")
async def record_metrics(request: Request, call_next):
    start = time.perf_counter()
    path = request.url.path

    response = await call_next(request)

    elapsed = time.perf_counter() - start
    method = request.method
    status_code = str(response.status_code)

    REQUEST_COUNT.labels(method=method, path=path, status_code=status_code).inc()
    REQUEST_LATENCY.labels(method=method, path=path).observe(elapsed)

    return response


@app.get("/health")
def health():
    """Liveness/readiness-style endpoint used by orchestrators and load balancers."""
    return {"status": "ok"}


@app.get("/api/info")
def api_info():
    """Small metadata endpoint — useful for debugging which version/build is running."""
    return {
        "service": "homelab-platform-api",
        "version": app.version,
        "environment": os.getenv("ENVIRONMENT", "local"),
    }


@app.get("/metrics", include_in_schema=False)
def metrics():
    """Prometheus scrape endpoint."""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
