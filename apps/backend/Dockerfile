# Base image: OS + Python runtime (read-only template layer stack)
FROM python:3.12-slim

WORKDIR /app

# Install dependencies first (better layer caching when only app code changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Document the port; does not publish it by itself (docker run -p does)
EXPOSE 8000

# Production-style server (no --reload)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
