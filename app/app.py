from flask import Flask, jsonify
from datetime import datetime, timezone
import os

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify({
        "application": "Balaji's DevOps Service",
        "status": "running",
        "message": "Application deployed successfully"
    })

@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200

@app.get("/info")
def info():
    return jsonify({
        "environment": os.getenv("APP_ENV", "development"),
        "version": os.getenv("APP_VERSION", "1.0.0")
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

