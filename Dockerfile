# Stage-1: Install dependencies into a self-contained folder
FROM cgr.dev/chainguard/python:latest-dev AS builder
WORKDIR /app

USER root
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/deps -r requirements.txt

# Stage-2: Zero-CVE Minimal Runtime
FROM cgr.dev/chainguard/python:latest AS runner
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Tell Chainguard's built-in /usr/bin/python where to find the installed packages
ENV PYTHONPATH=/app/deps

COPY --from=builder /app/deps /app/deps
COPY app.py .

EXPOSE 8000

# Chainguard's default ENTRYPOINT is ["/usr/bin/python"]
CMD ["-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
