import os
from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


@app.get("/ready")
def ready():
    # This sample has no external dependencies. Add dependency checks here
    # only when readiness genuinely depends on them; avoid making /health slow.
    return jsonify(ready=True), 200


@app.get("/version")
def version():
    return jsonify(version=os.getenv("APP_VERSION", "local")), 200


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    # Cloud Run injects PORT. Bind to all interfaces inside the container.
    app.run(host="0.0.0.0", port=port)
