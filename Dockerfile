# Stage-1: Build Dependencies (Keep Debian slim here since it is discarded later)
FROM python:3.11-slim AS builder
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage-2: Ultra-Minimal Distroless Runtime (Eliminates 95%+ of OS CVEs)
FROM gcr.io/distroless/python3-debian12:nonroot AS runner
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Point Python to the packages copied from Stage-1
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

COPY --from=builder /install /usr/local
COPY app.py .

EXPOSE 8000

# Distroless has no shell, so run uvicorn via python -m
CMD ["-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
