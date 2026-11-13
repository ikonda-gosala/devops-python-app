# Stage-1: Build Dependencies (Use Wolfi/Chainguard dev image to match runtime libraries)
FROM cgr.dev/chainguard/python:latest-dev AS builder
WORKDIR /app

USER root
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage-2: Zero-CVE Minimal Runtime
FROM cgr.dev/chainguard/python:latest AS runner
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Note: Check Python version in cgr.dev/chainguard/python (typically 3.12 or 3.13)
# Installing into a virtual environment avoids hardcoding Python version paths!
COPY --from=builder /install /usr/local
COPY app.py .

EXPOSE 8000

CMD ["-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
