import os

from fastapi import FastAPI

app = FastAPI(
    title="Homelab Platform API",
    version="0.1.0",
    description="Minimal backend for our GitOps learning platform.",
)


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
