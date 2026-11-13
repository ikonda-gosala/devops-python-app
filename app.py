from fastapi import FastAPI, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

app = FastAPI(title="GitOps DevOps App")

# 1. Define a custom application metric for Prometheus to track
REQUEST_COUNTER = Counter(
    "app_requests_total", 
    "Total number of HTTP requests processed by this pod"
)

@app.get("/")
def read_root():
    # Increment the metric every time a user hits the landing page
    REQUEST_COUNTER.inc()
    
    html_content = """
    <!DOCTYPE html>
    <html>
    <head><title>DevOps Project</title></head>
    <body style="font-family: Arial; text-align: center; margin-top: 100px; background-color: #f4f6f9;">
        <h1 style="color: #2c3e50;">🚀 Welcome to the Python GitOps Application!</h1>
        <p style="color: #7f8c8d; font-size: 18px;">Status: Running smoothly on AWS EKS via ArgoCD.</p>
    </body>
    </html>
    """
    return Response(content=html_content, media_type="text/html")

# 2. Production Liveness/Readiness Health Check Endpoint
@app.get("/health")
def health_check():
    return {"status": "UP", "engine": "Python/FastAPI"}

# 3. Prometheus Metrics Endpoint
@app.get("/metrics")
def metrics():
    # Generates the formatting Prometheus expects natively
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
