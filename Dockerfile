#Stage-1: Build Dependencies

FROM python:3.11-slim AS Builder
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends gcc

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# Stage-2: Minimal run time
FROM python:3.11-slim AS runner
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH=/root/.local/bin:$PATH

COPY --from=builder /root/.local /root/.local
COPY app.py .

RUN useradd -u 1001 appuser && chown -R appuser /app
USER appuser

EXPOSE 8000

# Start the web engine using Uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
